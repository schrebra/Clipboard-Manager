Set-StrictMode -Version Latest

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName PresentationFramework

# Create script-level variables
$script:notificationTimer = New-Object System.Windows.Forms.Timer
$script:notificationTimer.Interval = 2000
$script:lastClipboardText = ""
$script:mostRecentDisplayText = ""  # New variable to track the display text of most recent entry

# Create the main form
$form = New-Object System.Windows.Forms.Form
$form.Text = " Clipboard Manager"
$form.Size = New-Object System.Drawing.Size(492,430)
$form.StartPosition = "CenterScreen"
$form.BackColor = [System.Drawing.Color]::FromArgb(243, 243, 243)
$form.Font = New-Object System.Drawing.Font("Segoe UI", 12)
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle
$form.MaximizeBox = $false
$form.ShowIcon = $false 

# Create menu strip
$menuStrip = New-Object System.Windows.Forms.MenuStrip
$viewMenu = New-Object System.Windows.Forms.ToolStripMenuItem
$viewMenu.Text = "View"
$pinMenuItem = New-Object System.Windows.Forms.ToolStripMenuItem
$pinMenuItem.Text = "Pin Application"
$pinMenuItem.CheckOnClick = $true
$viewMenu.DropDownItems.Add($pinMenuItem)
$menuStrip.Items.Add($viewMenu)
$form.MainMenuStrip = $menuStrip
$form.Controls.Add($menuStrip)

# Create notification label
$notificationLabel = New-Object System.Windows.Forms.Label
$notificationLabel.Size = New-Object System.Drawing.Size(200, 30)
$notificationLabel.Location = New-Object System.Drawing.Point(150, 360)
$notificationLabel.Text = "Copied to clipboard"
$notificationLabel.ForeColor = [System.Drawing.Color]::FromArgb(68, 68, 68)
$notificationLabel.BackColor = [System.Drawing.Color]::FromArgb(242, 242, 242)
$notificationLabel.Font = New-Object System.Drawing.Font("Segoe UI", 12)
$notificationLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$notificationLabel.Visible = $false
$notificationLabel.BorderStyle = [System.Windows.Forms.BorderStyle]::None
$notificationLabel.Padding = New-Object System.Windows.Forms.Padding(5)
$form.Controls.Add($notificationLabel)

# Create the list box for clipboard items
$listBox = New-Object System.Windows.Forms.ListBox
$listBox.Location = New-Object System.Drawing.Point(10,30)
$listBox.Size = New-Object System.Drawing.Size(465,280)
$listBox.Font = New-Object System.Drawing.Font("Segoe UI", 12)
$listBox.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
$listBox.BackColor = [System.Drawing.Color]::White
$listBox.HorizontalScrollbar = $true
$listBox.ScrollAlwaysVisible = $true
$form.Controls.Add($listBox)

# Add pin toggle functionality
$pinMenuItem.Add_Click({
    $form.TopMost = $pinMenuItem.Checked
})

# Custom button function
function Create-CustomButton {
    param ($text, $location, $size, $color)
    $button = New-Object System.Windows.Forms.Button
    $button.Location = $location
    $button.Size = $size
    $button.Text = $text
    $button.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $button.BackColor = $color
    $button.ForeColor = [System.Drawing.Color]::Black
    $button.FlatAppearance.BorderColor = $color
    $button.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::FromArgb($color.R - 20, $color.G - 20, $color.B - 20)
    $button.Cursor = [System.Windows.Forms.Cursors]::Hand
    return $button
}

# Function to show notification
function Show-Notification {
    if ($script:notificationTimer.Enabled) {
        $script:notificationTimer.Stop()
    }
    
    $script:notificationTimer.Add_Tick({
        $notificationLabel.Visible = $false
        $script:notificationTimer.Stop()
    })
    
    $notificationLabel.Visible = $true
    $script:notificationTimer.Start()
}

# Create buttons
$copyButton = Create-CustomButton -text "Copy Selected" -location (New-Object System.Drawing.Point(10,320)) `
    -size (New-Object System.Drawing.Size(220,30)) `
    -color ([System.Drawing.Color]::FromArgb(204, 229, 255))
$form.Controls.Add($copyButton)

$clearButton = Create-CustomButton -text "Clear History" -location (New-Object System.Drawing.Point(255,320)) `
    -size (New-Object System.Drawing.Size(220,30)) `
    -color ([System.Drawing.Color]::FromArgb(255, 204, 204))
$form.Controls.Add($clearButton)

# Create a hashtable to store clipboard items
$clipboardHistory = @{}

# Create context menu for right-click
$contextMenu = New-Object System.Windows.Forms.ContextMenuStrip
$copyMenuItem = New-Object System.Windows.Forms.ToolStripMenuItem
$copyMenuItem.Text = "Copy to Clipboard"
$contextMenu.Items.Add($copyMenuItem)
$viewFullTextMenuItem = New-Object System.Windows.Forms.ToolStripMenuItem
$viewFullTextMenuItem.Text = "View Full Text"
$contextMenu.Items.Add($viewFullTextMenuItem)
$removeMenuItem = New-Object System.Windows.Forms.ToolStripMenuItem
$removeMenuItem.Text = "Remove Entry"
$contextMenu.Items.Add($removeMenuItem)
$listBox.ContextMenuStrip = $contextMenu

# Add context menu opening event
$contextMenu.Opening += {
    if ($listBox.SelectedItem) {
        $selectedItem = $listBox.SelectedItem
        # Disable "Remove Entry" if it's the most recent clipboard item
        $removeMenuItem.Enabled = ($selectedItem -ne $script:mostRecentDisplayText)
    }
}

# Button click events
$copyButton.Add_Click({
    if ($listBox.SelectedItem) {
        $selectedText = $clipboardHistory[$listBox.SelectedItem]
        [System.Windows.Forms.Clipboard]::SetText($selectedText)
        Show-Notification
    }
})

$clearButton.Add_Click({
    $listBox.Items.Clear()
    $clipboardHistory.Clear()
    [System.Windows.Forms.Clipboard]::Clear()
    $script:lastClipboardText = ""
    $script:mostRecentDisplayText = ""
})

$copyMenuItem.Add_Click({
    if ($listBox.SelectedItem) {
        $selectedText = $clipboardHistory[$listBox.SelectedItem]
        [System.Windows.Forms.Clipboard]::SetText($selectedText)
        Show-Notification
    }
})

$removeMenuItem.Add_Click({
    if ($listBox.SelectedItem) {
        $displayText = $listBox.SelectedItem
        $clipboardHistory.Remove($displayText)
        $listBox.Items.Remove($displayText)
    }
})

$viewFullTextMenuItem.Add_Click({
    if ($listBox.SelectedItem) {
        $displayText = $listBox.SelectedItem
        $fullText = $clipboardHistory[$displayText]
        $viewForm = New-Object System.Windows.Forms.Form
        $viewForm.Text = "Full Clipboard Text"
        $viewForm.Size = New-Object System.Drawing.Size(600,400)
        $viewForm.StartPosition = "CenterParent"
        $viewForm.BackColor = [System.Drawing.Color]::FromArgb(243, 243, 243)
        $viewForm.topmost = $true
        
        $textBox = New-Object System.Windows.Forms.TextBox
        $textBox.Multiline = $true
        $textBox.ScrollBars = "Vertical"
        $textBox.Location = New-Object System.Drawing.Point(10,10)
        $textBox.Size = New-Object System.Drawing.Size(565,340)
        $textBox.Text = $fullText
        $textBox.Font = New-Object System.Drawing.Font("Segoe UI", 12)
        $textBox.ReadOnly = $true

        
        $viewForm.Controls.Add($textBox)
        $viewForm.ShowDialog()
    }
})

# Timer for automatic clipboard checking
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 1000  # Check every second
$timer.Add_Tick({
    $currentClipboard = [System.Windows.Forms.Clipboard]::GetText()
    if ($currentClipboard -and $currentClipboard -ne $script:lastClipboardText) {
        $displayText = $currentClipboard -replace "`r`n|`n", " "  # Replace newlines with spaces
        $listBox.Items.Insert(0, $displayText)  # Insert at the top
        $clipboardHistory[$displayText] = $currentClipboard
        $script:lastClipboardText = $currentClipboard
        $script:mostRecentDisplayText = $displayText  # Update most recent display text
    }
})
$timer.Start()

# Add hover effect for list items
$listBox.Add_MouseMove({
    $index = $listBox.IndexFromPoint($listBox.PointToClient([Windows.Forms.Cursor]::Position))
    if ($index -ge 0) {
        $listBox.BackColor = [System.Drawing.Color]::FromArgb(248, 248, 248)
    } else {
        $listBox.BackColor = [System.Drawing.Color]::White
    }
})

# Form closing event to clean up timers
$form.Add_FormClosing({
    $timer.Stop()
    $script:notificationTimer.Stop()
    $timer.Dispose()
    $script:notificationTimer.Dispose()
})

# Show the form
$form.ShowDialog()