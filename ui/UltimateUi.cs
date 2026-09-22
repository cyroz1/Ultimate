using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Drawing;
using System.IO;
using System.Text;
using System.Text.RegularExpressions;
using System.Windows.Forms;

namespace UltimateUi
{
#if ULTIMATE_ARM64
    internal static class BuildIdentity
    {
        public const string Architecture = "arm64";
    }
#else
    internal static class BuildIdentity
    {
        public const string Architecture = "x64";
    }
#endif

    internal sealed class ScriptOption
    {
        public string Key;
        public string Label;

        public override string ToString()
        {
            return Key + ". " + Label;
        }
    }

    internal sealed class InputDefinition
    {
        public string Id;
        public string Label;
        public string Placeholder;
    }

    internal sealed class GuideEntry
    {
        public string RelativePath;
        public string Scope;
        public string Description;
    }

    internal sealed class ScriptDefinition
    {
        public string FullPath;
        public string RelativePath;
        public string Category;
        public string CategoryKey;
        public string Title;
        public string Scope;
        public string Description;
        public string Warning;
        public bool NeedsConfirmation;
        public readonly List<ScriptOption> Options = new List<ScriptOption>();
        public readonly List<InputDefinition> Inputs = new List<InputDefinition>();

        public override string ToString()
        {
            return Title;
        }
    }

    internal sealed class CategoryItem
    {
        public string Key;
        public string Name;
        public int Count;

        public override string ToString()
        {
            return Name + "  (" + Count + ")";
        }
    }

    internal sealed class ScriptRunner : IDisposable
    {
        private readonly object inputLock = new object();
        private readonly Process process;
        private bool disposed;

        public event Action<string, bool> Output;
        public event Action<int> Completed;

        public ScriptRunner(string root, string hostPath, string scriptPath, string architecture)
        {
            string powershell = Path.Combine(
                Environment.GetEnvironmentVariable("WINDIR") ?? @"C:\Windows",
                @"System32\WindowsPowerShell\v1.0\powershell.exe");

            if (!File.Exists(powershell))
            {
                powershell = "powershell.exe";
            }

            ProcessStartInfo startInfo = new ProcessStartInfo
            {
                FileName = powershell,
                Arguments = "-NoLogo -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File " +
                            Quote(hostPath) + " -ScriptPath " + Quote(scriptPath) +
                            " -Architecture " + Quote(architecture),
                WorkingDirectory = root,
                UseShellExecute = false,
                CreateNoWindow = true,
                WindowStyle = ProcessWindowStyle.Hidden,
                RedirectStandardInput = true,
                RedirectStandardOutput = true,
                RedirectStandardError = true,
                StandardOutputEncoding = Encoding.UTF8,
                StandardErrorEncoding = Encoding.UTF8
            };

            process = new Process
            {
                StartInfo = startInfo,
                EnableRaisingEvents = true
            };
            process.OutputDataReceived += OnOutputData;
            process.ErrorDataReceived += OnErrorData;
            process.Exited += OnExited;
        }

        public int ProcessId
        {
            get { return process.Id; }
        }

        public void Start()
        {
            process.Start();
            process.BeginOutputReadLine();
            process.BeginErrorReadLine();
        }

        public void SendInput(string value)
        {
            if (disposed || process.HasExited)
            {
                return;
            }

            lock (inputLock)
            {
                try
                {
                    process.StandardInput.WriteLine(value ?? "");
                    process.StandardInput.Flush();
                }
                catch (InvalidOperationException)
                {
                }
                catch (IOException)
                {
                }
            }
        }

        public void Cancel()
        {
            if (disposed)
            {
                return;
            }

            try
            {
                if (!process.HasExited)
                {
                    process.Kill();
                }
            }
            catch (InvalidOperationException)
            {
            }
            catch (NotSupportedException)
            {
            }
        }

        private void OnOutputData(object sender, DataReceivedEventArgs args)
        {
            if (args.Data != null && Output != null)
            {
                Output(args.Data, false);
            }
        }

        private void OnErrorData(object sender, DataReceivedEventArgs args)
        {
            if (args.Data != null && Output != null)
            {
                Output(args.Data, true);
            }
        }

        private void OnExited(object sender, EventArgs args)
        {
            try
            {
                process.WaitForExit();
            }
            catch (InvalidOperationException)
            {
            }

            int exitCode = -1;
            try
            {
                exitCode = process.ExitCode;
            }
            catch (InvalidOperationException)
            {
            }

            if (Completed != null)
            {
                Completed(exitCode);
            }
        }

        private static string Quote(string value)
        {
            return "\"" + value.Replace("\"", "\\\"") + "\"";
        }

        public void Dispose()
        {
            if (disposed)
            {
                return;
            }

            disposed = true;
            process.OutputDataReceived -= OnOutputData;
            process.ErrorDataReceived -= OnErrorData;
            process.Exited -= OnExited;
            process.Dispose();
        }
    }

    internal sealed class InputPrompt : Form
    {
        private readonly TextBox input;

        public string Value
        {
            get { return input.Text; }
        }

        public InputPrompt(string prompt)
        {
            Text = "Ultimate — input required";
            StartPosition = FormStartPosition.CenterParent;
            FormBorderStyle = FormBorderStyle.FixedDialog;
            MinimizeBox = false;
            MaximizeBox = false;
            ShowInTaskbar = false;
            ClientSize = new Size(470, 155);
            BackColor = Color.FromArgb(30, 41, 59);
            ForeColor = Color.FromArgb(226, 232, 240);
            Font = new Font("Segoe UI", 9F);

            Label promptLabel = new Label
            {
                AutoSize = false,
                Location = new Point(16, 16),
                Size = new Size(438, 42),
                Text = string.IsNullOrWhiteSpace(prompt) ? "PowerShell requested a value." : prompt,
                ForeColor = ForeColor
            };

            input = new TextBox
            {
                Location = new Point(16, 66),
                Size = new Size(438, 26),
                BackColor = Color.FromArgb(15, 23, 42),
                ForeColor = ForeColor,
                BorderStyle = BorderStyle.FixedSingle
            };

            Button cancel = new Button
            {
                Text = "Cancel",
                DialogResult = DialogResult.Cancel,
                Location = new Point(278, 110),
                Size = new Size(84, 28),
                FlatStyle = FlatStyle.Flat
            };
            Button ok = new Button
            {
                Text = "Continue",
                DialogResult = DialogResult.OK,
                Location = new Point(370, 110),
                Size = new Size(84, 28),
                FlatStyle = FlatStyle.Flat,
                BackColor = Color.FromArgb(45, 212, 191),
                ForeColor = Color.FromArgb(15, 23, 42)
            };

            Controls.Add(promptLabel);
            Controls.Add(input);
            Controls.Add(cancel);
            Controls.Add(ok);
            AcceptButton = ok;
            CancelButton = cancel;
        }
    }

    internal sealed class MainForm : Form
    {
        private const string InputMarker = "__ULTIMATE_INPUT__";
        private const string PauseMarker = "__ULTIMATE_PAUSE__";
        private const string FilePickerMarker = "__ULTIMATE_FILE_PICKER__";

        private static readonly Color Background = Color.FromArgb(15, 23, 42);
        private static readonly Color Surface = Color.FromArgb(30, 41, 59);
        private static readonly Color SurfaceLight = Color.FromArgb(51, 65, 85);
        private static readonly Color TextColor = Color.FromArgb(226, 232, 240);
        private static readonly Color Muted = Color.FromArgb(148, 163, 184);
        private static readonly Color Accent = Color.FromArgb(45, 212, 191);
        private static readonly Color Warning = Color.FromArgb(251, 191, 36);

        private readonly string root;
        private readonly string hostPath;
        private readonly List<GuideEntry> guideEntries;
        private readonly List<ScriptDefinition> scripts;
        private readonly List<ScriptDefinition> visibleScripts = new List<ScriptDefinition>();
        private readonly Dictionary<string, Control> inputControls = new Dictionary<string, Control>();
        private readonly List<RadioButton> optionButtons = new List<RadioButton>();

        private TextBox searchBox;
        private ListBox categoryList;
        private ListBox scriptList;
        private Label scriptCountLabel;
        private Label titleLabel;
        private Label metaLabel;
        private Label descriptionLabel;
        private Label warningLabel;
        private FlowLayoutPanel optionFlow;
        private TableLayoutPanel inputTable;
        private CheckBox confirmBox;
        private Button runButton;
        private Button cancelButton;
        private Label statusLabel;
        private RichTextBox outputBox;
        private ScriptDefinition currentScript;
        private ScriptRunner runner;

        public MainForm(string appRoot)
        {
            root = appRoot;
            hostPath = Path.Combine(root, "ui", "PowerShellHost.ps1");
            guideEntries = LoadGuideEntries();
            scripts = LoadScripts();

            Text = "Ultimate — Windows Toolkit";
            Text += " (" + BuildIdentity.Architecture + ")";
            StartPosition = FormStartPosition.CenterScreen;
            MinimumSize = new Size(980, 650);
            Size = new Size(1220, 820);
            BackColor = Background;
            ForeColor = TextColor;
            Font = new Font("Segoe UI", 9F);

            BuildLayout();
            PopulateCategories();
            ApplyScriptFilter();
        }

        private void BuildLayout()
        {
            TableLayoutPanel outer = new TableLayoutPanel
            {
                Dock = DockStyle.Fill,
                ColumnCount = 1,
                RowCount = 3,
                BackColor = Background,
                Padding = new Padding(12)
            };
            outer.RowStyles.Add(new RowStyle(SizeType.Absolute, 76));
            outer.RowStyles.Add(new RowStyle(SizeType.Percent, 100));
            outer.RowStyles.Add(new RowStyle(SizeType.Absolute, 34));

            Panel header = new Panel { Dock = DockStyle.Fill, BackColor = Surface };
            Label brand = new Label
            {
                Text = "ULTIMATE",
                Font = new Font("Segoe UI Semibold", 19F, FontStyle.Bold),
                ForeColor = Accent,
                AutoSize = true,
                Location = new Point(18, 11)
            };
            Label subtitle = new Label
            {
                Text = "Windows tuning toolkit  /  " + BuildIdentity.Architecture +
                       " GUI  /  " + scripts.Count + " PowerShell scripts  /  native controls  /  hidden PowerShell host",
                Font = new Font("Segoe UI", 9F),
                ForeColor = Muted,
                AutoSize = true,
                Location = new Point(20, 45)
            };
            Label admin = new Label
            {
                Text = "ADMINISTRATOR MODE",
                Font = new Font("Segoe UI Semibold", 8F, FontStyle.Bold),
                ForeColor = Warning,
                AutoSize = true,
                Anchor = AnchorStyles.Top | AnchorStyles.Right,
                Location = new Point(1000, 29)
            };
            header.Resize += delegate
            {
                admin.Left = header.ClientSize.Width - admin.Width - 20;
            };
            header.Controls.Add(brand);
            header.Controls.Add(subtitle);
            header.Controls.Add(admin);

            SplitContainer body = new SplitContainer
            {
                Dock = DockStyle.Fill,
                SplitterDistance = 300,
                SplitterWidth = 6,
                BackColor = Surface,
                FixedPanel = FixedPanel.Panel1
            };

            BuildNavigation(body.Panel1);
            BuildDetails(body.Panel2);

            Panel footer = new Panel { Dock = DockStyle.Fill, BackColor = Background };
            statusLabel = new Label
            {
                Dock = DockStyle.Fill,
                TextAlign = ContentAlignment.MiddleLeft,
                ForeColor = Muted,
                Text = "Ready. Select a script to review its controls."
            };
            footer.Controls.Add(statusLabel);

            outer.Controls.Add(header, 0, 0);
            outer.Controls.Add(body, 0, 1);
            outer.Controls.Add(footer, 0, 2);
            Controls.Add(outer);
        }

        private void BuildNavigation(Control parent)
        {
            TableLayoutPanel nav = new TableLayoutPanel
            {
                Dock = DockStyle.Fill,
                ColumnCount = 1,
                RowCount = 6,
                BackColor = Surface,
                Padding = new Padding(12)
            };
            nav.RowStyles.Add(new RowStyle(SizeType.Absolute, 25));
            nav.RowStyles.Add(new RowStyle(SizeType.Absolute, 32));
            nav.RowStyles.Add(new RowStyle(SizeType.Absolute, 25));
            nav.RowStyles.Add(new RowStyle(SizeType.Absolute, 112));
            nav.RowStyles.Add(new RowStyle(SizeType.Absolute, 25));
            nav.RowStyles.Add(new RowStyle(SizeType.Percent, 100));

            Label library = new Label
            {
                Text = "SCRIPT LIBRARY",
                Dock = DockStyle.Fill,
                ForeColor = Muted,
                Font = new Font("Segoe UI Semibold", 8F, FontStyle.Bold),
                TextAlign = ContentAlignment.MiddleLeft
            };
            searchBox = new TextBox
            {
                Dock = DockStyle.Fill,
                BackColor = Background,
                ForeColor = TextColor,
                BorderStyle = BorderStyle.FixedSingle
            };
            searchBox.TextChanged += delegate { ApplyScriptFilter(); };

            Label categoryLabel = new Label
            {
                Text = "CATEGORIES",
                Dock = DockStyle.Fill,
                ForeColor = Muted,
                Font = new Font("Segoe UI Semibold", 8F, FontStyle.Bold),
                TextAlign = ContentAlignment.MiddleLeft
            };
            categoryList = CreateListBox();
            categoryList.SelectedIndexChanged += delegate { ApplyScriptFilter(); };
            scriptCountLabel = new Label
            {
                Text = "SCRIPTS",
                Dock = DockStyle.Fill,
                ForeColor = Muted,
                Font = new Font("Segoe UI Semibold", 8F, FontStyle.Bold),
                TextAlign = ContentAlignment.MiddleLeft
            };
            scriptList = CreateListBox();
            scriptList.SelectedIndexChanged += delegate { RenderSelectedScript(); };

            nav.Controls.Add(library, 0, 0);
            nav.Controls.Add(searchBox, 0, 1);
            nav.Controls.Add(categoryLabel, 0, 2);
            nav.Controls.Add(categoryList, 0, 3);
            nav.Controls.Add(scriptCountLabel, 0, 4);
            nav.Controls.Add(scriptList, 0, 5);

            parent.Controls.Add(nav);
        }

        private void BuildDetails(Control parent)
        {
            TableLayoutPanel details = new TableLayoutPanel
            {
                Dock = DockStyle.Fill,
                ColumnCount = 1,
                RowCount = 4,
                BackColor = Background,
                Padding = new Padding(14, 10, 10, 10)
            };
            details.RowStyles.Add(new RowStyle(SizeType.Absolute, 154));
            details.RowStyles.Add(new RowStyle(SizeType.Absolute, 230));
            details.RowStyles.Add(new RowStyle(SizeType.Absolute, 48));
            details.RowStyles.Add(new RowStyle(SizeType.Percent, 100));

            Panel info = new Panel { Dock = DockStyle.Fill, BackColor = Background };
            titleLabel = new Label
            {
                Text = "Choose a script",
                AutoSize = false,
                Location = new Point(0, 0),
                Size = new Size(700, 38),
                ForeColor = TextColor,
                Font = new Font("Segoe UI Semibold", 19F, FontStyle.Bold)
            };
            metaLabel = new Label
            {
                Text = "",
                AutoSize = false,
                Location = new Point(0, 38),
                Size = new Size(900, 24),
                Anchor = AnchorStyles.Top | AnchorStyles.Left | AnchorStyles.Right,
                ForeColor = Accent,
                Font = new Font("Segoe UI", 9F)
            };
            descriptionLabel = new Label
            {
                Text = "Select an item from the library to see its options.",
                AutoSize = false,
                Location = new Point(0, 67),
                Size = new Size(900, 52),
                Anchor = AnchorStyles.Top | AnchorStyles.Left | AnchorStyles.Right,
                ForeColor = Muted
            };
            warningLabel = new Label
            {
                Text = "",
                AutoSize = false,
                Location = new Point(0, 125),
                Size = new Size(900, 24),
                Anchor = AnchorStyles.Top | AnchorStyles.Left | AnchorStyles.Right,
                ForeColor = Warning,
                Font = new Font("Segoe UI Semibold", 8.5F, FontStyle.Bold)
            };
            info.Controls.Add(titleLabel);
            info.Controls.Add(metaLabel);
            info.Controls.Add(descriptionLabel);
            info.Controls.Add(warningLabel);

            TableLayoutPanel selection = new TableLayoutPanel
            {
                Dock = DockStyle.Fill,
                ColumnCount = 2,
                RowCount = 1,
                BackColor = Background,
                Margin = new Padding(0)
            };
            selection.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 58));
            selection.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 42));

            GroupBox optionGroup = new GroupBox
            {
                Text = "ACTION",
                Dock = DockStyle.Fill,
                ForeColor = Muted,
                BackColor = Surface,
                Padding = new Padding(12, 22, 12, 10),
                Margin = new Padding(0, 0, 8, 0)
            };
            optionFlow = new FlowLayoutPanel
            {
                Dock = DockStyle.Fill,
                AutoScroll = true,
                WrapContents = true,
                FlowDirection = FlowDirection.LeftToRight,
                BackColor = Surface,
                Padding = new Padding(0)
            };
            optionGroup.Controls.Add(optionFlow);

            GroupBox inputGroup = new GroupBox
            {
                Text = "DETAILS",
                Dock = DockStyle.Fill,
                ForeColor = Muted,
                BackColor = Surface,
                Padding = new Padding(12, 22, 12, 10),
                Margin = new Padding(8, 0, 0, 0)
            };
            inputTable = new TableLayoutPanel
            {
                Dock = DockStyle.Fill,
                ColumnCount = 2,
                AutoScroll = true,
                BackColor = Surface,
                Padding = new Padding(0)
            };
            inputTable.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 40));
            inputTable.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 60));
            inputGroup.Controls.Add(inputTable);

            selection.Controls.Add(optionGroup, 0, 0);
            selection.Controls.Add(inputGroup, 1, 0);

            FlowLayoutPanel actions = new FlowLayoutPanel
            {
                Dock = DockStyle.Fill,
                BackColor = Background,
                FlowDirection = FlowDirection.LeftToRight,
                WrapContents = false,
                Padding = new Padding(0, 7, 0, 0)
            };
            confirmBox = new CheckBox
            {
                AutoSize = true,
                Text = "I understand this may change system settings",
                ForeColor = Muted,
                Checked = false,
                Margin = new Padding(0, 4, 18, 0)
            };
            runButton = new Button
            {
                Text = "Run selected script",
                Width = 150,
                Height = 30,
                FlatStyle = FlatStyle.Flat,
                BackColor = Accent,
                ForeColor = Background,
                Enabled = false,
                Margin = new Padding(0, 0, 8, 0)
            };
            cancelButton = new Button
            {
                Text = "Stop",
                Width = 78,
                Height = 30,
                FlatStyle = FlatStyle.Flat,
                BackColor = SurfaceLight,
                ForeColor = TextColor,
                Enabled = false,
                Margin = new Padding(0)
            };
            runButton.Click += delegate { RunSelectedScript(); };
            cancelButton.Click += delegate { CancelRunningScript(); };
            actions.Controls.Add(confirmBox);
            actions.Controls.Add(runButton);
            actions.Controls.Add(cancelButton);

            GroupBox outputGroup = new GroupBox
            {
                Text = "ACTIVITY",
                Dock = DockStyle.Fill,
                ForeColor = Muted,
                BackColor = Surface,
                Padding = new Padding(10, 22, 10, 10)
            };
            outputBox = new RichTextBox
            {
                Dock = DockStyle.Fill,
                ReadOnly = true,
                DetectUrls = true,
                BackColor = Color.FromArgb(2, 6, 23),
                ForeColor = TextColor,
                BorderStyle = BorderStyle.None,
                Font = new Font("Consolas", 9F),
                WordWrap = false,
                ScrollBars = RichTextBoxScrollBars.Both
            };
            outputGroup.Controls.Add(outputBox);

            details.Controls.Add(info, 0, 0);
            details.Controls.Add(selection, 0, 1);
            details.Controls.Add(actions, 0, 2);
            details.Controls.Add(outputGroup, 0, 3);
            parent.Controls.Add(details);
        }

        private ListBox CreateListBox()
        {
            return new ListBox
            {
                Dock = DockStyle.Fill,
                BackColor = Surface,
                ForeColor = TextColor,
                BorderStyle = BorderStyle.None,
                IntegralHeight = false,
                SelectionMode = SelectionMode.One,
                Font = new Font("Segoe UI", 9F)
            };
        }

        private void PopulateCategories()
        {
            categoryList.Items.Clear();
            categoryList.Items.Add(new CategoryItem { Key = "*", Name = "All scripts", Count = scripts.Count });

            Dictionary<string, CategoryItem> byKey = new Dictionary<string, CategoryItem>();
            foreach (ScriptDefinition script in scripts)
            {
                CategoryItem item;
                if (!byKey.TryGetValue(script.CategoryKey, out item))
                {
                    item = new CategoryItem { Key = script.CategoryKey, Name = script.Category, Count = 0 };
                    byKey.Add(script.CategoryKey, item);
                }
                item.Count++;
            }

            List<CategoryItem> categories = new List<CategoryItem>(byKey.Values);
            categories.Sort(delegate(CategoryItem left, CategoryItem right)
            {
                return string.Compare(left.Key, right.Key, StringComparison.OrdinalIgnoreCase);
            });
            foreach (CategoryItem item in categories)
            {
                categoryList.Items.Add(item);
            }
            categoryList.SelectedIndex = 0;
        }

        private void ApplyScriptFilter()
        {
            if (scriptList == null || categoryList == null)
            {
                return;
            }

            string categoryKey = "*";
            CategoryItem selectedCategory = categoryList.SelectedItem as CategoryItem;
            if (selectedCategory != null)
            {
                categoryKey = selectedCategory.Key;
            }
            string query = searchBox == null ? "" : searchBox.Text.Trim();

            visibleScripts.Clear();
            foreach (ScriptDefinition script in scripts)
            {
                bool categoryMatches = categoryKey == "*" || script.CategoryKey == categoryKey;
                bool queryMatches = query.Length == 0 ||
                                    script.Title.IndexOf(query, StringComparison.OrdinalIgnoreCase) >= 0 ||
                                    script.RelativePath.IndexOf(query, StringComparison.OrdinalIgnoreCase) >= 0 ||
                                    script.Scope.IndexOf(query, StringComparison.OrdinalIgnoreCase) >= 0 ||
                                    script.Description.IndexOf(query, StringComparison.OrdinalIgnoreCase) >= 0;
                if (categoryMatches && queryMatches)
                {
                    visibleScripts.Add(script);
                }
            }

            visibleScripts.Sort(delegate(ScriptDefinition left, ScriptDefinition right)
            {
                int category = string.Compare(left.CategoryKey, right.CategoryKey, StringComparison.OrdinalIgnoreCase);
                if (category != 0) return category;
                return string.Compare(left.RelativePath, right.RelativePath, StringComparison.OrdinalIgnoreCase);
            });

            scriptList.BeginUpdate();
            scriptList.Items.Clear();
            foreach (ScriptDefinition script in visibleScripts)
            {
                scriptList.Items.Add(script);
            }
            scriptList.EndUpdate();
            scriptCountLabel.Text = "SCRIPTS  /  " + visibleScripts.Count;
            if (visibleScripts.Count > 0)
            {
                scriptList.SelectedIndex = 0;
            }
            else
            {
                currentScript = null;
                RenderEmptyScript();
            }
        }

        private void RenderSelectedScript()
        {
            ScriptDefinition selected = scriptList.SelectedItem as ScriptDefinition;
            if (selected == null)
            {
                RenderEmptyScript();
                return;
            }

            currentScript = selected;
            titleLabel.Text = selected.Title;
            metaLabel.Text = selected.Category + "   ·   " + selected.RelativePath + "   ·   Scope: " + selected.Scope;
            descriptionLabel.Text = selected.Description;
            warningLabel.Text = selected.Warning;
            warningLabel.ForeColor = selected.NeedsConfirmation ? Warning : Muted;
            confirmBox.Checked = false;
            runButton.Enabled = true;
            RenderOptions(selected);
            RenderInputs(selected);
            outputBox.Clear();
            statusLabel.Text = "Ready to run " + selected.Title + ".";
        }

        private void RenderEmptyScript()
        {
            currentScript = null;
            titleLabel.Text = "Choose a script";
            metaLabel.Text = "";
            descriptionLabel.Text = "Select an item from the library to see its options.";
            warningLabel.Text = "";
            optionFlow.Controls.Clear();
            inputTable.Controls.Clear();
            inputControls.Clear();
            optionButtons.Clear();
            confirmBox.Checked = false;
            runButton.Enabled = false;
        }

        private void RenderOptions(ScriptDefinition script)
        {
            optionFlow.Controls.Clear();
            optionButtons.Clear();

            if (script.Options.Count == 0)
            {
                Label noOptions = new Label
                {
                    Text = "This script has no menu choices. Review the activity log, then run it when ready.",
                    AutoSize = false,
                    Width = 470,
                    Height = 42,
                    ForeColor = Muted,
                    Margin = new Padding(0, 4, 0, 0)
                };
                optionFlow.Controls.Add(noOptions);
                return;
            }

            foreach (ScriptOption option in script.Options)
            {
                RadioButton button = new RadioButton
                {
                    Text = option.ToString(),
                    Tag = option.Key,
                    AutoSize = false,
                    Width = 245,
                    Height = 27,
                    ForeColor = TextColor,
                    BackColor = Surface,
                    Margin = new Padding(0, 2, 12, 2),
                    FlatStyle = FlatStyle.Flat
                };
                optionButtons.Add(button);
                optionFlow.Controls.Add(button);
            }
            if (optionButtons.Count > 0)
            {
                optionButtons[0].Checked = true;
            }
        }

        private void RenderInputs(ScriptDefinition script)
        {
            inputTable.Controls.Clear();
            inputTable.RowStyles.Clear();
            inputTable.RowCount = Math.Max(1, script.Inputs.Count);
            inputControls.Clear();

            if (script.Inputs.Count == 0)
            {
                Label noInputs = new Label
                {
                    Text = "No additional values required.",
                    AutoSize = false,
                    Dock = DockStyle.Fill,
                    ForeColor = Muted,
                    TextAlign = ContentAlignment.TopLeft
                };
                inputTable.Controls.Add(noInputs, 0, 0);
                inputTable.SetColumnSpan(noInputs, 2);
                return;
            }

            int row = 0;
            foreach (InputDefinition definition in script.Inputs)
            {
                inputTable.RowStyles.Add(new RowStyle(SizeType.Absolute, 38));
                Label label = new Label
                {
                    Text = definition.Label,
                    Dock = DockStyle.Fill,
                    ForeColor = TextColor,
                    TextAlign = ContentAlignment.MiddleLeft,
                    Margin = new Padding(0, 0, 8, 0)
                };
                Control input;
                if (definition.Id == "priority")
                {
                    ComboBox priority = new ComboBox
                    {
                        Dock = DockStyle.Fill,
                        DropDownStyle = ComboBoxStyle.DropDownList,
                        BackColor = Background,
                        ForeColor = TextColor,
                        FlatStyle = FlatStyle.Flat
                    };
                    priority.Items.AddRange(new object[]
                    {
                        "1 — Real Time",
                        "2 — High",
                        "3 — Above Normal",
                        "4 — Normal",
                        "5 — Below Normal",
                        "6 — Idle / Low"
                    });
                    priority.SelectedIndex = 3;
                    input = priority;
                }
                else
                {
                    TextBox text = new TextBox
                    {
                        Dock = DockStyle.Fill,
                        BackColor = Background,
                        ForeColor = TextColor,
                        BorderStyle = BorderStyle.FixedSingle,
                        Text = definition.Id == "account" ? Environment.UserName : ""
                    };
                    input = text;
                }
                inputControls[definition.Id] = input;
                inputTable.Controls.Add(label, 0, row);
                inputTable.Controls.Add(input, 1, row);
                row++;
            }
        }

        private void RunSelectedScript()
        {
            if (currentScript == null || runner != null)
            {
                return;
            }

            if (currentScript.NeedsConfirmation && !confirmBox.Checked)
            {
                MessageBox.Show(this,
                    "Please confirm that you reviewed the selected action before running it.",
                    "Review required", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            string validationError = ValidateInputs();
            if (validationError.Length > 0)
            {
                MessageBox.Show(this, validationError, "Input required", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            if (!File.Exists(hostPath))
            {
                MessageBox.Show(this, "The hidden PowerShell host is missing: " + hostPath,
                    "Installation error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }

            outputBox.Clear();
            AppendOutput("Starting " + currentScript.Title + "...", false);
            AppendOutput("PowerShell is running without a console window.", false);
            runButton.Enabled = false;
            cancelButton.Enabled = true;
            statusLabel.Text = "Running " + currentScript.Title + "...";

            runner = new ScriptRunner(root, hostPath, currentScript.FullPath, BuildIdentity.Architecture);
            runner.Output += HandleRunnerOutput;
            runner.Completed += HandleRunnerCompleted;
            try
            {
                runner.Start();
            }
            catch (Exception error)
            {
                AppendOutput(error.ToString(), true);
                FinishRun(-1);
            }
        }

        private string ValidateInputs()
        {
            string path = currentScript.RelativePath.Replace('\\', '/');
            string option = GetSelectedOption();

            if (path == "2 Refresh/4 Autounattend.ps1")
            {
                if (GetInputValue("account").Length == 0 || GetInputValue("usb").Length == 0)
                    return "Enter an account name and USB drive letter before creating the unattended file.";
            }
            if (path == "2 Refresh/5 Updates Drivers Block.ps1" && (option == "2" || option == "5"))
            {
                if (GetInputValue("usb").Length == 0)
                    return "Enter the USB drive letter used for the bootable setup files.";
            }
            if ((path == "8 Advanced/8 Smt Ht.ps1" || path == "8 Advanced/9 Core 1 Thread 1.ps1") && option == "1")
            {
                if (GetInputValue("process").Length == 0)
                    return "Enter the process ID shown by the script before applying the setting.";
            }
            if (path == "8 Advanced/10 Priority.ps1" && option == "1")
            {
                if (GetInputValue("process").Length == 0)
                    return "Enter the process ID to change while it is running.";
            }
            return "";
        }

        private void CancelRunningScript()
        {
            if (runner == null)
            {
                return;
            }
            statusLabel.Text = "Stopping...";
            runner.Cancel();
        }

        private void HandleRunnerOutput(string line, bool isError)
        {
            if (IsDisposed)
            {
                return;
            }
            if (line.StartsWith(FilePickerMarker, StringComparison.Ordinal))
            {
                ResolveFilePicker(line.Substring(FilePickerMarker.Length));
                return;
            }
            if (line.StartsWith(InputMarker, StringComparison.Ordinal))
            {
                string prompt = line.Substring(InputMarker.Length);
                ResolvePrompt(prompt);
                return;
            }
            if (line == PauseMarker)
            {
                runner.SendInput("");
                return;
            }
            BeginInvoke((Action)delegate { AppendOutput(line, isError); });
        }

        private void ResolvePrompt(string prompt)
        {
            string value;
            if (TryResolveKnownPrompt(prompt, out value))
            {
                runner.SendInput(value);
                return;
            }

            BeginInvoke((Action)delegate
            {
                using (InputPrompt dialog = new InputPrompt(prompt))
                {
                    if (dialog.ShowDialog(this) == DialogResult.OK)
                    {
                        if (runner != null) runner.SendInput(dialog.Value);
                    }
                    else
                    {
                        CancelRunningScript();
                    }
                }
            });
        }

        private void ResolveFilePicker(string filter)
        {
            BeginInvoke((Action)delegate
            {
                if (runner == null)
                {
                    return;
                }

                using (OpenFileDialog dialog = new OpenFileDialog())
                {
                    dialog.Title = "Select downloaded driver";
                    dialog.CheckFileExists = true;
                    dialog.Multiselect = false;
                    dialog.RestoreDirectory = true;
                    try
                    {
                        dialog.Filter = string.IsNullOrWhiteSpace(filter)
                            ? "All Files (*.*)|*.*"
                            : filter;
                    }
                    catch (ArgumentException)
                    {
                        dialog.Filter = "All Files (*.*)|*.*";
                    }

                    DialogResult result = dialog.ShowDialog(this);
                    if (runner != null)
                    {
                        runner.SendInput(result == DialogResult.OK ? dialog.FileName : "");
                    }
                }
            });
        }

        private bool TryResolveKnownPrompt(string prompt, out string value)
        {
            string normalized = (prompt ?? "").Trim();
            if (normalized.Length == 0 && optionButtons.Count > 0)
            {
                value = GetSelectedOption();
                return true;
            }

            string upper = normalized.ToUpperInvariant();
            if (upper.Contains("USB") || upper.Contains("DRIVE LETTER"))
            {
                value = GetInputValue("usb");
                return true;
            }
            if (upper.Contains("ACCOUNT NAME"))
            {
                value = GetInputValue("account");
                return true;
            }
            if (upper.Contains("EXE ID") || upper.Contains("PROCESS ID"))
            {
                value = GetInputValue("process");
                return true;
            }
            if (upper == "PRIORITY" || upper.Contains("PRIORITY"))
            {
                value = GetInputValue("priority");
                return true;
            }

            value = "";
            return false;
        }

        private string GetSelectedOption()
        {
            foreach (RadioButton button in optionButtons)
            {
                if (button.Checked)
                {
                    return button.Tag as string ?? "";
                }
            }
            return "";
        }

        private string GetInputValue(string id)
        {
            Control control;
            if (!inputControls.TryGetValue(id, out control))
            {
                return "";
            }
            ComboBox combo = control as ComboBox;
            if (combo != null)
            {
                return (combo.SelectedIndex + 1).ToString();
            }
            TextBox text = control as TextBox;
            string value = text == null ? "" : text.Text.Trim();
            if (id == "usb")
            {
                value = value.TrimEnd(':', '\\', '/');
            }
            return value;
        }

        private void HandleRunnerCompleted(int exitCode)
        {
            if (IsDisposed)
            {
                return;
            }
            BeginInvoke((Action)delegate { FinishRun(exitCode); });
        }

        private void FinishRun(int exitCode)
        {
            if (exitCode == 0)
            {
                AppendOutput("Completed successfully.", false);
                statusLabel.Text = "Completed " + (currentScript == null ? "script" : currentScript.Title) + ".";
            }
            else
            {
                AppendOutput("Stopped or failed with exit code " + exitCode + ".", true);
                statusLabel.Text = "Stopped or failed.";
            }
            runButton.Enabled = currentScript != null;
            cancelButton.Enabled = false;
            if (runner != null)
            {
                runner.Dispose();
                runner = null;
            }
        }

        private void AppendOutput(string line, bool isError)
        {
            if (outputBox == null || outputBox.IsDisposed)
            {
                return;
            }
            outputBox.SelectionStart = outputBox.TextLength;
            outputBox.SelectionLength = 0;
            outputBox.SelectionColor = isError ? Color.FromArgb(248, 113, 113) : TextColor;
            outputBox.AppendText(line + Environment.NewLine);
            outputBox.SelectionColor = TextColor;
            outputBox.ScrollToCaret();
        }

        protected override void OnFormClosing(FormClosingEventArgs e)
        {
            if (runner != null)
            {
                runner.Cancel();
                runner.Dispose();
                runner = null;
            }
            base.OnFormClosing(e);
        }

        private List<GuideEntry> LoadGuideEntries()
        {
            List<GuideEntry> result = new List<GuideEntry>();
            string guidePath = Path.Combine(root, "SCRIPT_GUIDE.md");
            if (!File.Exists(guidePath))
            {
                return result;
            }

            try
            {
                foreach (string line in File.ReadAllLines(guidePath))
                {
                    Match match = Regex.Match(line,
                        @"^\|\s*\[([^\]]+)\]\(<([^>]+)>\)\s*\|\s*([^|]+?)\s*\|\s*(.*?)\s*\|$");
                    if (!match.Success)
                    {
                        continue;
                    }

                    result.Add(new GuideEntry
                    {
                        RelativePath = match.Groups[2].Value.Replace('\\', '/'),
                        Scope = match.Groups[3].Value.Trim(),
                        Description = match.Groups[4].Value.Trim()
                    });
                }
            }
            catch
            {
                return new List<GuideEntry>();
            }

            result.Sort(delegate(GuideEntry left, GuideEntry right)
            {
                return string.Compare(left.RelativePath, right.RelativePath, StringComparison.OrdinalIgnoreCase);
            });
            return result;
        }

        private List<ScriptDefinition> LoadScripts()
        {
            List<ScriptDefinition> result = new List<ScriptDefinition>();
            Dictionary<string, GuideEntry> guideByPath =
                new Dictionary<string, GuideEntry>(StringComparer.OrdinalIgnoreCase);
            foreach (GuideEntry entry in guideEntries)
            {
                guideByPath[entry.RelativePath] = entry;
            }

            string[] paths = Directory.GetFiles(root, "*.ps1", SearchOption.AllDirectories);
            foreach (string path in paths)
            {
                string relative = path.Substring(root.Length).TrimStart(Path.DirectorySeparatorChar, Path.AltDirectorySeparatorChar);
                string normalized = relative.Replace('\\', '/');
                if (normalized.StartsWith("ui/", StringComparison.OrdinalIgnoreCase) ||
                    normalized.StartsWith("build/", StringComparison.OrdinalIgnoreCase) ||
                    normalized.StartsWith(".github/", StringComparison.OrdinalIgnoreCase))
                {
                    continue;
                }

                string firstPart = normalized.Contains("/") ? normalized.Substring(0, normalized.IndexOf('/')) : "Bootstrap";
                Match categoryMatch = Regex.Match(firstPart, @"^(\d+)\s+(.+)$");
                string categoryKey = categoryMatch.Success ? categoryMatch.Groups[1].Value.PadLeft(3, '0') : "999";
                string category = categoryMatch.Success ? categoryMatch.Groups[2].Value : "Bootstrap";

                string fileTitle = Path.GetFileNameWithoutExtension(path);
                fileTitle = Regex.Replace(fileTitle, @"^\d+\s+", "");
                GuideEntry guide;
                string description = MakeDescription(normalized, fileTitle);
                string scope = "Not documented";
                if (guideByPath.TryGetValue(normalized, out guide))
                {
                    description = guide.Description;
                    scope = guide.Scope;
                }

                ScriptDefinition definition = new ScriptDefinition
                {
                    FullPath = path,
                    RelativePath = normalized,
                    Category = category,
                    CategoryKey = categoryKey,
                    Title = fileTitle,
                    Scope = scope,
                    Description = description,
                    Warning = MakeWarning(normalized),
                    NeedsConfirmation = !IsInformational(normalized)
                };

                string source;
                try
                {
                    source = File.ReadAllText(path);
                }
                catch
                {
                    source = "";
                }
                ParseOptions(source, definition.Options);
                AddKnownInputs(normalized, source, definition.Inputs);
                result.Add(definition);
            }

            result.Sort(delegate(ScriptDefinition left, ScriptDefinition right)
            {
                return string.Compare(left.RelativePath, right.RelativePath, StringComparison.OrdinalIgnoreCase);
            });
            return result;
        }

        private static void ParseOptions(string source, List<ScriptOption> destination)
        {
            MatchCollection matches = Regex.Matches(source,
                @"(?im)^\s*Write-Host\s+[""']\s*(\d+)\.\s*(.*?)[""']",
                RegexOptions.Multiline);
            int first = -1;
            for (int index = 0; index < matches.Count; index++)
            {
                if (matches[index].Groups[1].Value == "1")
                {
                    first = index;
                    break;
                }
            }
            if (first < 0)
            {
                return;
            }

            int expected = 1;
            for (int index = first; index < matches.Count; index++)
            {
                int number;
                if (!int.TryParse(matches[index].Groups[1].Value, out number) || number != expected)
                {
                    break;
                }
                string label = matches[index].Groups[2].Value
                    .Replace("`n", "")
                    .Replace("`r", "")
                    .Trim();
                destination.Add(new ScriptOption { Key = number.ToString(), Label = label });
                expected++;
            }
        }

        private static void AddKnownInputs(string relative, string source, List<InputDefinition> destination)
        {
            if (relative == "2 Refresh/4 Autounattend.ps1")
            {
                destination.Add(new InputDefinition { Id = "account", Label = "Account name", Placeholder = "" });
                destination.Add(new InputDefinition { Id = "usb", Label = "USB drive letter (e.g. E)", Placeholder = "" });
            }
            else if (relative == "2 Refresh/5 Updates Drivers Block.ps1")
            {
                destination.Add(new InputDefinition { Id = "usb", Label = "USB drive letter (e.g. E)", Placeholder = "" });
            }
            else if (relative == "8 Advanced/8 Smt Ht.ps1" || relative == "8 Advanced/9 Core 1 Thread 1.ps1")
            {
                destination.Add(new InputDefinition { Id = "process", Label = "Process ID (option 1)", Placeholder = "" });
            }
            else if (relative == "8 Advanced/10 Priority.ps1")
            {
                destination.Add(new InputDefinition { Id = "priority", Label = "Priority choice", Placeholder = "" });
                destination.Add(new InputDefinition { Id = "process", Label = "Process ID (option 1)", Placeholder = "" });
            }
        }

        private static string MakeDescription(string relative, string title)
        {
            if (relative.Equals("IWR.ps1", StringComparison.OrdinalIgnoreCase))
            {
                return "Bootstrapper: downloads the upstream source toolkit into a desktop folder and opens it.";
            }
            return "Runs the original " + title + " automation with its menu choices and prompts supplied by this UI.";
        }

        private static bool IsInformational(string relative)
        {
            string upper = relative.ToUpperInvariant();
            return (upper.Contains("CHECK/") && !upper.Contains("BIOS")) || upper.Contains("POLLING RATE TEST") ||
                   upper.Contains("BUFFERBLOAT TEST") || upper.Contains("PC BUILD GUIDE") ||
                   upper.Contains("MONITOR OPTIMIZATION") || upper.Contains("NETWORK DRIVER") ||
                   upper.Contains("MOUSE POLLING RATE TEST");
        }

        private static string MakeWarning(string relative)
        {
            string upper = relative.ToUpperInvariant();
            if (upper.Contains("FACTORY RESET") || upper.Contains("REINSTALL") || upper.Contains("BITLOCKER") ||
                upper.Contains("CLEANUP") || upper.Contains("BLOATWARE") || upper.Contains("DEFENDER") ||
                upper.Contains("UPDATES DRIVERS BLOCK") || upper.Contains("DRIVER CLEAN") || upper.Contains("AUTOUNATTEND"))
            {
                return "Review carefully: this may remove data, alter recovery/update/security behavior, or require a reboot.";
            }
            if (upper.Contains("BIOS"))
            {
                return "Review carefully: this action will restart the computer into firmware setup.";
            }
            if (upper.Contains("IWR.PS1"))
            {
                return "Bootstrapper: downloads and launches the upstream repository contents.";
            }
            return "Administrator rights are required; some actions change Windows settings or open another Windows tool.";
        }
    }

    internal static class Program
    {
        [STAThread]
        private static void Main()
        {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            string root = Application.StartupPath;
            Application.Run(new MainForm(root));
        }
    }
}
