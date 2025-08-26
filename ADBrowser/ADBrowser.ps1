# DONE: При запуске приложения нужно заполнять дерево OU-шками и Container-ами, + функция обновления
# DONE: Заменить listbox2 на grid c полями cn, sn, givenName, mail, sAMAccountName, dn (последнее скрыть)
# DONE: Заменить listbox1 на grid
# DONE: Поиск по нажатию Enter в поле запроса
# TODO: рисование папочек в дереве
# DONE: запуск полезных утилит вместо калькулятора

function OnApplicationLoad {
	Set-Variable -Name neededProp -Value ("distinguishedName", "cn", "employeeID", "sAMAccountName", "userAccountControl") -Scope "global"
	Set-Variable -Name columnHeaders -Value ("Status", "cn", "sn", "givenName", "userPrincipalName", "sAMAccountName", "distinguishedName", "mail") -Scope "global"
	return $true #return true for success or false for failure
}


function OnApplicationExit {
	#Note: This function is not called in Projects
	#Note: This function runs after the form is closed
	#TODO: Add custom code to clean up and unload snapins when the application exitsз
	
	$script:ExitCode = 0 #Set the exit code for the Packager
}

function Call-Demo-TreeView_pff {
	#----------------------------------------------
	#region Import the Assemblies
	#----------------------------------------------
	[void][reflection.assembly]::Load("System, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
	[void][reflection.assembly]::Load("System.Windows.Forms, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
	[void][reflection.assembly]::Load("System.Drawing, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a")
	[void][reflection.assembly]::Load("mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
	#endregion Import Assemblies
	#----------------------------------------------
	#region Generated Form Objects
	#----------------------------------------------
	[System.Windows.Forms.Application]::EnableVisualStyles()
	$form1 = New-Object 'System.Windows.Forms.Form'
	$splitcontainer1 = New-Object 'System.Windows.Forms.SplitContainer'
	$splitcontainerMain = New-Object 'System.Windows.Forms.SplitContainer'
	$splitcontainerBottom = New-Object 'System.Windows.Forms.SplitContainer'
	$buttonSearch = New-Object 'System.Windows.Forms.Button'
	#$buttonExit = New-Object 'System.Windows.Forms.Button'
	$treeviewNav = New-Object 'System.Windows.Forms.TreeView'
	$imagelistLargeImages = New-Object 'System.Windows.Forms.ImageList'
	$imagelistSmallImages = New-Object 'System.Windows.Forms.ImageList'
	$listbox1 = New-Object 'System.Windows.Forms.ListBox'
	$dgvDetails = New-Object 'System.Windows.Forms.DataGridView'
	$dgvResults = New-Object 'System.Windows.Forms.DataGridView'
	$listbox2 = New-Object 'System.Windows.Forms.ListBox'
	$textBox1 = New-Object 'System.Windows.Forms.TextBox'
	$ContextMenu1 = New-Object 'System.Windows.Forms.ContextMenuStrip'
	$ToolStripTextBox1 = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$ToolStripTextBox2 = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$ToolStripTextBox3 = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$ToolStripTextBox4 = New-Object 'System.Windows.Forms.ToolStripMenuItem'
	$ComboBox1 = New-Object 'System.Windows.Forms.ComboBox'
	$InitialFormWindowState = New-Object 'System.Windows.Forms.FormWindowState'
	#endregion Generated Form Objects
	#----------------------------------------------
	# User Generated Script
	#----------------------------------------------
	
$FormEvent_Load={
	#$domain=[adsi]"LDAP://dc=wheelset,dc=railsystems,dc=kz"
    #$domain=[adsi]"GC://dc=railsystems,dc=kz"
    $domain=[adsi]""
	$newnode=New-Object System.Windows.Forms.TreeNode 
    $newnode.Name=$domain.Name
 	$newnode.Text=$domain.distinguishedName
	$newnode.Tag=$domain.distinguishedName
	$treeviewNav.Nodes.Add($newnode)
	Remove-Variable newnode
	
	foreach ($n in $treeviewNav.Nodes) {
		$children=([adsi]"LDAP://$($n.Tag)").Children
		foreach($child in $children){
			if($child){
				$newnode=New-Object System.Windows.Forms.TreeNode 
			    $newnode.Name=$child.Name
			 	$newnode.Text=$child.Name
				$newnode.Tag=$child.distinguishedName
				$n.Nodes.Add($newnode)
				Remove-Variable newnode
				}
			}
		Remove-Variable children
		}
	$treeviewNav.Nodes[0].Expand()
	$treeviewNav.SelectedNode = $treeviewNav.Nodes[0].Nodes["EEC"]
	$textBox1.Select()
	
	#Write-Host $splitcontainerMain.Size
	#Write-Host $splitcontainerMain.Location
	Write-Host [System.Windows.Forms.FixedPanel]::Panel1
	Write-Host $splitcontainerBottom.FixedPanel
	Write-Host 'splitcontainerBottom.Size', $splitcontainerMain.Size
	Write-Host 'splitcontainerBottom.Panel1', $splitcontainerBottom.Panel1.Size
	}

$treeviewNav_AfterSelect=[System.Windows.Forms.TreeViewEventHandler]{
	Show-ObjectDetails $treeviewNav.SelectedNode.Tag
}

$treeviewNav_DoubleClick={
	$node=$treeviewNav.SelectedNode
	if($node.Nodes.Count -eq 0){
		#$children=([adsi]"<LDAP://$($node.Tag)>;(|(objectClass=domainDNS)(objectClass=container)(objectClass=organizationalUnit));name,distinguishedName").Children
		$children=([adsi]"LDAP://$($node.Tag)").Children
		foreach($child in $children){
			if($child){
				$newnode=New-Object System.Windows.Forms.TreeNode 
			    $newnode.Name=$child.Name
			 	$newnode.Text=$child.Name
				$newnode.Tag=$child.distinguishedName
				$node.Nodes.Add($newnode)
			}
		}
		$node.Expand()
		Show-ObjectDetails $node.Tag
	}
}
	
$buttonSearch_Click = {
	$nodeS = $treeviewNav.SelectedNode
	Search-ObjectUser $nodeS.Tag
	}
	#
	# Поиск элементов
	#

function Search-ADUserByField {
    param (
        [string]$DomainName,
        [string]$FieldName,
        [string]$Criteria
    )

	if ($DomainName -eq $null) {
            $domain=[adsi]"GC://dc=railsystems,dc=kz"
            #Write-Host "Scenario #1"
		} else {
			$domain = [adsi]"LDAP://$DomainName"
            #Write-Host "Scenario #2"
		}
	$searcher = [adsisearcher]$domain
	$searcher.Filter = '(&(objectClass=user)('+$FieldName+'='+$Criteria+'))'
#    (!userAccountControl:1.2.840.113556.1.4.803:=2)
	$result = $searcher.FindAll()
    if ($result) {
            return $result
    } else {
        return @()
    }
}

function Search-ObjectUser($distinguisedName){
    $cn = $ComboBox1.Text
    $searchStr = $textBox1.Text 
    
    $userResult = @()
    $userResult += Search-ADUserByField -DomainName "dc=railsystems,dc=kz" -FieldName $cn -Criteria $searchStr
    $userResult += Search-ADUserByField -DomainName "dc=akk,dc=railsystems,dc=kz" -FieldName $cn -Criteria $searchStr
    $userResult += Search-ADUserByField -DomainName "dc=pmk,dc=railsystems,dc=kz" -FieldName $cn -Criteria $searchStr
    $userResult += Search-ADUserByField -DomainName "dc=pmkz,dc=railsystems,dc=kz" -FieldName $cn -Criteria $searchStr
    $userResult += Search-ADUserByField -DomainName "dc=tower,dc=basis,dc=asia" -FieldName $cn -Criteria $searchStr
    $userResult += Search-ADUserByField -DomainName "dc=corp,dc=rws,dc=kz" -FieldName $cn -Criteria $searchStr

    $listbox2.Items.Clear()
    if($userResult){
        $userResult | foreach {
            $listbox2.Items.add($_.Properties.cn[0])
        }
    }
    
    # Для DataGridView
$dgvResults.Rows.Clear()
    if ($userResult) {
        $cnt = $userResult.Count

        foreach ($record in $userResult) {
            $row = @()

            $buff = [int]$record.Properties["userAccountControl"][0]
            $enableStatus = ($buff -band 2) -eq 0
            $lockoutTime = [datetime]::FromFileTimeUtc($record.Properties["lockoutTime"][0])
            $isLockedOut = $lockoutTime -ne [datetime]::FromFileTimeUtc(0)
            Write-Host '>>>', $record.Properties["userPrincipalName"], $record.Properties["userAccountControl"], $enableStatus, $isLockedOut

            $enableImage = $null

            if (!$enableStatus) {
                $enableImage = [System.Drawing.Bitmap]::FromFile("red_circle.png")
            } else {
                $enableImage = [System.Drawing.Bitmap]::FromFile("blue_circle.png")
    
                $pwdLastSet = $record.Properties["pwdLastSet"]
                if ($pwdLastSet -ne $null -and $pwdLastSet.Length -gt 0) {
                    $passwordLastSet = [datetime]::FromFileTimeUtc($pwdLastSet[0])
                    $expirationDate = $passwordLastSet.AddDays(40)

                    $userAccountControl = [int]$record.Properties["userAccountControl"][0]
                    $pwdNeverExpires = ($userAccountControl -band 65536) -eq 65536

                    $currentDate = Get-Date

                    if (($currentDate -lt $expirationDate -and !$pwdNeverExpires) -or
                        ($currentDate -lt $expirationDate -and $pwdNeverExpires) -or
                        ($currentDate -ge $expirationDate -and $pwdNeverExpires)) {
                        $enableImage = [System.Drawing.Bitmap]::FromFile("yellow_circle.png")

                        if (!$isLockedOut) {
                            $enableImage = [System.Drawing.Bitmap]::FromFile("green_circle.png")
                        }
                    }
              
                } else {
                    Write-Host "Атрибут pwdLastSet не найден или пуст для пользователя:", $record.Properties["userPrincipalName"]
                }
            }

            $row += $enableImage

            foreach ($header in $columnHeaders[1..($columnHeaders.Length - 1)]) {
                $value = $record.Properties[$header]
                if ($value -ne $null -and $value.Length -gt 0) {
                    $row += $value[0]
                } else {
                    $row += ""
                }
            }
            Write-Host 'PasswordNeverExpires:', $pwdNeverExpires
            Write-Host 'PasswordLastSet:', $passwordLastSet

            $dgvResults.Rows.Add($row)
        }
    }
}
function Show-ObjectDetails($distinguisedName){
	$item=[adsi]"LDAP://$distinguisedName"
#		KZ.ENRC.COM/EEC/Clients/Users/Aksu/Kramnyuk Alexey (u840803350640)
#		cn=Kramnyuk Alexey (u840803350640),ou=Aksu,ou=Users,ou=Clients,ou=EEC,dc=KZ,dc=ENRC,dc=COM
#		$item=[adsi]"LDAP://cn=Kramnyuk Alexey (u840803350640),ou=Aksu,ou=Users,ou=Clients,ou=EEC,dc=KZ,dc=ENRC,dc=COM"
#	[System.Windows.Forms.MessageBox]::Show($dgvDetails.Rows.Count)
	$dgvDetails.Rows.Clear()
	
	foreach ($prop in $neededProp) {
        $value=$item.Properties[$prop]
	    $row = @( $prop, $value[0])
		if ($dgvDetails.Rows.Count -eq $neededProp.Length) {
				$dgvDetails.Rows[$dgvDetails.Rows.Count - 1].SetValues($row)
			} else {
        		$dgvDetails.Rows.Add($row)
			}
    }
}
# Создание столбца DataGridViewImageColumn
    $imageColumn = New-Object System.Windows.Forms.DataGridViewImageColumn
    $imageColumn.Name = "Status"
    $imageColumn.HeaderText = "Status"
    $imageColumn.Width = 60
    $dgvResults.Columns.Add($imageColumn)


#Add-Type -Assembly System.Windows.Forms

	# form1
	#
	#$form1.Controls.Add($splitcontainer1)
	#$form1.Controls.Add($buttonSearch)
	#$form1.Controls.Add($textBox1)
	#$form1.Controls.Add($ComboBox1)
	#$form1.Controls.Add($dgvResults)
	$form1.Controls.Add($splitcontainerMain)
	$form1.ClientSize = '800, 600'
	$form1.Name = "form1"
	$form1.StartPosition = 'CenterScreen'
	$form1.Text = "Active Directory"
	$form1.add_Load($FormEvent_Load)
	#
	# splitcontainerMain
	#
	#$splitcontainerMain.Anchor = 'Top, Bottom, Left, Right'
	$splitcontainerMain.Dock = 'Fill'
	$splitcontainerMain.Orientation = 'Horizontal'
	#$splitcontainerMain.Location = '12, 12'
	$splitcontainerMain.Name = "splitcontainerMain"
	$splitcontainerMain.Panel1MinSize = 300
	$splitcontainerMain.Panel2MinSize = 300
	[void]$splitcontainerMain.Panel1.Controls.Add($splitcontainer1)
	[void]$splitcontainerMain.Panel2.Controls.Add($splitcontainerBottom)
	#$splitcontainerMain.Size = '800, 600'
	#$splitcontainerMain.Location = '0, 0'
	#$splitcontainerMain.SplitterDistance = 300
	#$splitcontainerMain.TabIndex = 3
	#
	# splitcontainer1
	#
	#$splitcontainer1.Anchor = 'Top, Bottom, Left, Right'
	$splitcontainer1.Dock = 'Fill'
	$splitcontainer1.Orientation = 'Vertical'
	#$splitcontainer1.Location = '12, 12'
	$splitcontainer1.Name = "splitcontainer1"
	$splitcontainer1.Panel1MinSize = 250
	$splitcontainer1.Panel2MinSize = 150
	[void]$splitcontainer1.Panel1.Controls.Add($treeviewNav)
	[void]$splitcontainer1.Panel2.Controls.Add($dgvDetails)
	#$splitcontainer1.Size = '600, 341'
	$splitcontainer1.SplitterDistance = 250
	$splitcontainer1.TabIndex = 3
	#
	# splitcontainerBottom
	#
	#$splitcontainerBottom.Anchor = 'Top, Bottom, Left, Right'
	$splitcontainerBottom.Dock = 'Fill'
	$splitcontainerBottom.Orientation = 'Horizontal'
	#$splitcontainerBottom.Location = '12, 12'
	$splitcontainerBottom.Name = "splitcontainerBottom"
	#$splitcontainerBottom.Panel1.Height = 50
	$splitcontainerBottom.Panel1MinSize = 32
	$splitcontainerBottom.Panel2MinSize = 64
	[void]$splitcontainerBottom.Panel1.Controls.Add($ComboBox1)
	[void]$splitcontainerBottom.Panel1.Controls.Add($textBox1)
	[void]$splitcontainerBottom.Panel1.Controls.Add($buttonSearch)
	[void]$splitcontainerBottom.Panel2.Controls.Add($dgvResults)
	#$splitcontainerBottom.Size = '600, 341'
	$splitcontainerBottom.SplitterDistance = 32
	#$splitcontainerBottom.TabIndex = 3
	$splitcontainerBottom.FixedPanel = [System.Windows.Forms.FixedPanel]::Panel1
	#https://info.sapien.com/index.php/how-to/powershell-studio-howto/sapien-how-to-work-with-resizing-form-and-anchoring-controls
	#
	# buttonSearch
	#
	#$buttonSearch.DialogResult = 'OK'
	#$buttonSearch.Location = '350, 351'
	$buttonSearch.Location = '350, 5'
	$buttonSearch.Name = "buttonSearch"
	$buttonSearch.Size = '75, 23'
	$buttonSearch.TabIndex = 4
	$buttonSearch.Text = "Search"
	$buttonSearch.add_Click($buttonSearch_Click)
	$buttonSearch.UseVisualStyleBackColor = $True
	$buttonSearch.Enabled = $false
	#
	# treeviewNav
	#
	$treeviewNav.Dock = 'Fill'
	$treeviewNav.Location = '1, 1'
	$treeviewNav.Name = "treeviewNav"
	#$treeviewNav.Size = '199, 341'
	$treeviewNav.TabIndex = 0
	$treeviewNav.Tag = ""
	$treeviewNav.HideSelection = $false
	$treeviewNav.add_AfterSelect($treeviewNav_AfterSelect)
	$treeviewNav.add_DoubleClick($treeviewNav_DoubleClick)
	#
	# imagelistLargeImages
	#
	$imagelistLargeImages.ColorDepth = 'Depth32Bit'
	$imagelistLargeImages.ImageSize = '32, 32'
	$imagelistLargeImages.TransparentColor = 'Transparent'
	#
	# imagelistSmallImages
	#
	$imagelistSmallImages.ColorDepth = 'Depth32Bit'
	$imagelistSmallImages.ImageSize = '16, 16'
	$imagelistSmallImages.TransparentColor = 'Transparent'
	#
	# dgvDetails
	#	
	$dgvDetails.Dock = 'Fill'
	#$dgvDetails.Size = '440, 341'
	$dgvDetails.DataBindings.DefaultDataSourceUpdateMode = 0
	$dgvDetails.Name = "dgvDetails"
	$dgvDetails.DataMember = ""
	$dgvDetails.TabIndex = 0
	$dgvDetails.Location = '1, 1'
	$dgvDetails.ColumnCount = 2
	$dgvDetails.ColumnHeadersVisible = $false
	$dgvDetails.RowHeadersVisible = $false
	$dgvDetails.Columns[0].AutoSizeMode = 'AllCells'
	$dgvDetails.Columns[1].AutoSizeMode = 'AllCells'
	$dgvDetails.ReadOnly = $true
	$dgvDetails.AllowUserToAddRows = $false
	#
	# dgvResults
	#
	#$dgvResults.Anchor = 'Top, Bottom, Left, Right'
	$dgvResults.Dock = 'Fill'
	#$dgvResults.Size = '790, 210'
	$dgvResults.DataBindings.DefaultDataSourceUpdateMode = 0
	$dgvResults.Name = "dgvResults"
	$dgvResults.DataMember = ""
	$dgvResults.TabIndex = 0
	#$dgvResults.Location = '5, 380'
	$dgvResults.ColumnCount = $columnHeaders.Length
	$dgvResults.ColumnHeadersVisible = $true
	$dgvResults.RowHeadersVisible = $true
	$dgvResults.ContextMenuStrip = $ContextMenu1
	$dgvResults.ReadOnly = $true
	$dgvResults.AllowUserToAddRows = $false
	$dgvResults.MultiSelect = $false
	$i = 0
	foreach ($header in $columnHeaders) {
		$dgvResults.Columns[$i].Name = $header
		$dgvResults.Columns[$i].AutoSizeMode = 'AllCells'
		$i++
	}
	#
	#$textBox1
	#
	#$textBox1.Location = '110, 351'
	$textBox1.Location = '110, 5'
	$textBox1.Size = '230, 40'
	$textBox1.Text = "*"
	$textBox1.add_KeyDown({
		if ($textBox1.Text.Replace("*","").Length -gt 1) {
			if ($_.KeyCode -eq "Enter") {
					Search-ObjectUser $treeviewNav.SelectedNode.Tag
				}
			if ($_.KeyCode -eq "Escape") {
					$dgvResults.Rows.Clear()
					$textBox1.Text = "*"
				}
			}
		})
	$textBox1.add_KeyUp({
		if ($textBox1.Text.Replace("*","").Length -gt 1) {
			$buttonSearch.Enabled = $true
			} else {
			$buttonSearch.Enabled = $false		
			}
		})
	$handler = ({
#		[System.Windows.Forms.MessageBox]::Show($this.text+" Clicked! ")
		# $this содержит ссылку на MenuItem, который был нажат
		if ($dgvResults.SelectedCells -ne $null) {
			switch ($this.Tag) 
    			{
				"unlock" {
					Start-Process "C:\scripts\hta\UnlockADUser.vbs" $('"LDAP://' + $dgvResults.CurrentCell.OwningRow.Cells["distinguishedName"].Value + '"')
					}        			
        		"reset" {
					# "C:\scripts\hta\UnlockUserAndChangePassword.vbs"
					Start-Process "C:\scripts\hta\UnlockUserAndChangePassword.vbs" $('"LDAP://' + $dgvResults.CurrentCell.OwningRow.Cells["distinguishedName"].Value + '"')
					}
        		"form" {
					# "C:\scripts\hta\PrincipalIdentification.hta"
					#Start-Process calc.exe
					Start-Process "C:\scripts\hta\PrincipalIdentification.hta" $('"LDAP://' + $dgvResults.CurrentCell.OwningRow.Cells["distinguishedName"].Value + '"')
					}
        		default {
					#[System.Windows.Forms.MessageBox]::Show($this.text+" Clicked! "+$dgvResults.CurrentCell.OwningRow.Cells["cn"].Value)
					Start-Process mmc.exe dsa.msc
					}
    			}
			}
		})
	
	#
	#$ToolStripTextBox1
	#
	$ToolStripTextBox1.Size = '150,20'
	$ToolStripTextBox1.Text = "Unlock"
	$ToolStripTextBox1.Tag = "unlock"
	$ToolStripTextBox1.add_Click($handler)
	#
	#$ToolStripTextBox2
	#
	$ToolStripTextBox2.Size = '150,20'
	$ToolStripTextBox2.Text = "Unlock and Reset..."
	$ToolStripTextBox2.Tag = "reset"
	$ToolStripTextBox2.add_Click($handler)
	#
	#$ToolStripTextBox3
	#
	$ToolStripTextBox3.Size = '150,20'
	$ToolStripTextBox3.Text = "Form..."
	$ToolStripTextBox3.Tag = "form"
	$ToolStripTextBox3.add_Click($handler)
	#
	#
	#$ToolStripTextBox4
	#
	$ToolStripTextBox4.Size = '150,20'
	$ToolStripTextBox4.Text = "Start ADUC from here..."
	$ToolStripTextBox4.Tag = "aduc"
	$ToolStripTextBox4.add_Click($handler)
	#
	#
	#$ContextMenu1
	#
	$ContextMenu1.Size = '200,66'
	$ContextMenu1.Items.Add($ToolStripTextBox1)
	$ContextMenu1.Items.Add($ToolStripTextBox2)
	$ContextMenu1.Items.Add($ToolStripTextBox3)
	$ContextMenu1.Items.Add($ToolStripTextBox4)
	#
	#$ComboBox1
	#
	#$ComboBox1.Location = '5, 350'
	$ComboBox1.Location = '5, 5'
	$ComboBox1.Size = '100, 30'
	$ComboBox1.Text = "sn"
	$ComboBox1.Items.Add("sAMAccountName")
	$ComboBox1.Items.Add("sn")
	$ComboBox1.Items.Add("givenName")
	#endregion Generated Form Code
	#----------------------------------------------
	#Save the initial state of the form
	$InitialFormWindowState = $form1.WindowState
	#Init the OnLoad event to correct the initial state of the form
	$form1.add_Load($Form_StateCorrection_Load)
	#Clean up the control events
	$form1.add_FormClosed($Form_Cleanup_FormClosed)
	#Show the Form
	return $form1.ShowDialog()
} #End Function
#Call OnApplicationLoad to initialize
if((OnApplicationLoad) -eq $true)
{
	#Call the form
	Call-Demo-TreeView_pff | Out-Null
	#Perform cleanup
	OnApplicationExit
}