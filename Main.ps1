#========================================================================
# Author 	: Kevin RAHETILAHY                                          #
#========================================================================

##############################################################
#                      LOAD ASSEMBLY                         #
##############################################################

[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')  				| out-null
[System.Reflection.Assembly]::LoadWithPartialName('presentationframework') 				| out-null
[System.Reflection.Assembly]::LoadWithPartialName('PresentationCore')      				| out-null
[System.Reflection.Assembly]::LoadFrom('assembly\MahApps.Metro.dll')       				| out-null
[System.Reflection.Assembly]::LoadFrom('assembly\System.Windows.Interactivity.dll') 	| out-null
[System.Windows.Forms.Application]::EnableVisualStyles()

##############################################################
#                      LOAD FUNCTION                         #
##############################################################
                      
function LoadXml ($Global:filename)
{
    $XamlLoader=(New-Object System.Xml.XmlDocument)
    $XamlLoader.Load($filename)
    return $XamlLoader
}

# Load MainWindow
$XamlMainWindow=LoadXml(".\Main.xaml")
$Reader=(New-Object System.Xml.XmlNodeReader $XamlMainWindow)
$Form=[Windows.Markup.XamlReader]::Load($Reader)

# ===============================================
# ======== Load TemplateWindow ==================
# ===============================================
$xamlDialog  = LoadXml(".\template\Dialog.xaml")
$read=(New-Object System.Xml.XmlNodeReader $xamlDialog)
$DialogForm=[Windows.Markup.XamlReader]::Load( $read )

# Create a new Dialog attached to Main Form 
$CustomDialog         = [MahApps.Metro.Controls.Dialogs.CustomDialog]::new($Form)

# Specifiy the content of the Custom dialog with the new 
# dialog form created.
$CustomDialog.AddChild($DialogForm)

# ===============================================
# ======== Load Sample Window ===================
# ===============================================
$xamlDialog  = LoadXml(".\template\Sample.xaml")
$read=(New-Object System.Xml.XmlNodeReader $xamlDialog)
$SampleForm=[Windows.Markup.XamlReader]::Load( $read )

# Create another Dialog attached to Main Form
$SampleDialog         = [MahApps.Metro.Controls.Dialogs.CustomDialog]::new($Form)

# Specifiy the content of the Sample dialog 
$SampleDialog.AddChild($SampleForm)

# ===============================================
# ===  Metro Dialog Settings                  === 
# ===============================================
$settings             = [MahApps.Metro.Controls.Dialogs.MetroDialogSettings]::new()
$settings.ColorScheme = [MahApps.Metro.Controls.Dialogs.MetroDialogColorScheme]::Theme


##############################################################
#                CONTROL INITIALIZATION                      #
##############################################################

# === Inside main xaml ===
$datagridtest   = $Form.FindName("gridLogs")
$showSample     = $Form.FindName("btntest")

# === Inside Dialog Template ===
$dialgComputerName  = $DialogForm.FindName("dialgComputerName")
$dialgIPAdress      = $DialogForm.FindName("dialgIPAdress")
$dialgDomain        = $DialogForm.FindName("dialgDomain")
$dialgPatched       = $DialogForm.FindName("dialgPatched")    
$DialogClose        = $DialogForm.FindName("BtnClose")
$iconDialog         = $DialogForm.FindName("iconDialog")


# === Inside sample Dialog ===
$closeMe            = $SampleForm.FindName("closeMe")

# ===  Window Resources   ==== 
$ApplicationResources = $Form.Resources.MergedDictionaries
$VisualBrush = $iconDialog.Child.OpacityMask.Visual.Children


##############################################################
#                DATAS EXAMPLE                               #
##############################################################

# observablCollection is easier to handle :)
$script:observableCollection = [System.Collections.ObjectModel.ObservableCollection[Object]]::new()

# Row 1
$objArray = New-Object PSObject
$objArray | Add-Member -type NoteProperty -name ComputerName -value "Computer_03"
$objArray | Add-Member -type NoteProperty -name IP_Adress -value "192.168.0.0"
$objArray | Add-Member -type NoteProperty -name Domain -value "Domain0"
$objArray | Add-Member -type NoteProperty -name Patch -value $true
$script:observableCollection.Add($objArray) | Out-Null

# Row 3
$objArray = New-Object PSObject
$objArray | Add-Member -type NoteProperty -name ComputerName -value "Computer_10"
$objArray | Add-Member -type NoteProperty -name IP_Adress -value "192.168.1.1"
$objArray | Add-Member -type NoteProperty -name Domain -value "Domain2"
$objArray | Add-Member -type NoteProperty -name Patch -value $true
$script:observableCollection.Add($objArray) | Out-Null

# Row 2         
$objArray = New-Object PSObject
$objArray | Add-Member -type NoteProperty -name ComputerName -value "Computer_32"
$objArray | Add-Member -type NoteProperty -name IP_Adress -value "192.168.2.0"
$objArray | Add-Member -type NoteProperty -name Domain -value "Domain3"
$objArray | Add-Member -type NoteProperty -name Patch -value $false
$script:observableCollection.Add($objArray) | Out-Null

# Add datas to the datagrid
$datagridtest.ItemsSource = $Script:observableCollection

##############################################################
#                FUNCTIONS                                   #
##############################################################

# Function view a row
Function viewRow($rowObj){ 
    
    # ==== VIEW ICON  === 
    $iconDialog.Background.Color = "#FF44AFE3"
    $VisualBrush.RemoveAt(0)
    $VisualBrush.Add($ApplicationResources[0].Item("appbar_magnify"))

    # Disable inputs
    $dialgComputerName.IsEnabled = $false
    $dialgIPAdress.IsEnabled     = $false
    $dialgDomain.IsEnabled       = $false
    $dialgPatched.IsEnabled      = $false
    
    # Fill inputs with selected object
    $dialgComputerName.Text = $rowObj.ComputerName
    $dialgIPAdress.Text     = $rowObj.IP_Adress
    $dialgDomain.Text       = $rowObj.Domain
    $dialgPatched.Text      = $rowObj.Patch

    # Show custom dialog form
    [MahApps.Metro.Controls.Dialogs.DialogManager]::ShowMetroDialogAsync($Form, $CustomDialog, $settings)


}

# Function to view a row
Function editRow($rowObj){ 
    
    # ==== EDIT ICON  === 
    $iconDialog.Background.Color = "#198C19"
    $VisualBrush.RemoveAt(0)
    $VisualBrush.Add($ApplicationResources[0].Item("appbar_edit"))

    # Enable inputs
    $dialgComputerName.IsEnabled = $true
    $dialgIPAdress.IsEnabled     = $true
    $dialgDomain.IsEnabled       = $true
    $dialgPatched.IsEnabled      = $true

    # fill content with the selected object
    $dialgComputerName.Text = $rowObj.ComputerName
    $dialgIPAdress.Text     = $rowObj.IP_Adress
    $dialgDomain.Text       = $rowObj.Domain
    $dialgPatched.Text      = $rowObj.Patch

    # Show custom dialog form
    [MahApps.Metro.Controls.Dialogs.DialogManager]::ShowMetroDialogAsync($Form, $CustomDialog, $settings)    

}

# Function to remove row
Function removeRow($rowObj){
    $script:observableCollection.Remove($rowObj)
}

##############################################################
#                MANAGE EVENT ON PANEL                       #
##############################################################

# close the sample dialog
$closeMe.add_Click({
    # Close the Custom Dialog
    $SampleDialog.RequestCloseAsync()    
})

# show the sample dialog
$showSample.add_Click({
    [MahApps.Metro.Controls.Dialogs.DialogManager]::ShowMetroDialogAsync($Form, $SampleDialog, $settings)
})

# Close the dialog from within the dialog
$DialogClose.add_Click({

    # Update and refresh the content of the datagrid 
    $index = $observableCollection.IndexOf($resultObj)
    $script:observableCollection[$index].ComputerName   = $dialgComputerName.Text
    $script:observableCollection[$index].IP_Adress      = $dialgIPAdress.Text 
    $script:observableCollection[$index].Domain         = $dialgDomain.Text
    $script:observableCollection[$index].Patch          = $dialgPatched.Text
    $datagridtest.Items.Refresh()

    # Close the Custom Dialog
    $CustomDialog.RequestCloseAsync()

})


[System.Windows.RoutedEventHandler]$EventonDataGrid = {

    # GET THE NAME OF EVENT SOURCE
    $button =  $_.OriginalSource.Name

    # THIS RETURN THE ROW DATA AVAILABLE
    # resultObj scope is the whole script because we need  
    # it to update values when the dialog is closed.
    $Script:resultObj = $datagridtest.CurrentItem

    # CHOOSE THE CORRESPONDING ACTION
    If ( $button -match "View" ){
        Write-Host "View row"
        viewRow -rowObj $resultObj
    }
    ElseIf ($button -match "Edit" ){    
        Write-Host "Edit row"
        editRow -rowObj $resultObj

    }
    ElseIf ($button -match "Delete" ){
        Write-Host "Remove row"
        removeRow -rowObj $resultObj
    }

}
$datagridtest.AddHandler([System.Windows.Controls.Button]::ClickEvent, $EventonDataGrid)


##############################################################
#                SHOW WINDOW                                 #
##############################################################
$Form.ShowDialog() | Out-Null

