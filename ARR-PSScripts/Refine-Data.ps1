$data = Import-Csv .\All_Dashboards.csv

$allWidgets = @()
foreach($item in $data)
{
    foreach($section in $item.widgets.Replace("widthAsPercentage",'^').Split("^"))
    {
        $widget = New-Object –TypeName PSObject
        $widget | Add-Member –MemberType NoteProperty –Name Dashboard_Title –Value ''
        $widget | Add-Member –MemberType NoteProperty –Name Dashboard_Description –Value ''
        $widget | Add-Member –MemberType NoteProperty –Name Instance –Value ''
        $widget | Add-Member –MemberType NoteProperty –Name Widget_Title –Value ''
        $widget | Add-Member –MemberType NoteProperty –Name Widget_Description –Value ''
        $widget | Add-Member -MemberType NoteProperty –Name Widget_Query –Value ''

        $tempWidget = $widget
        $tempWidget.Dashboard_Title = $item.title
        $tempWidget.Dashboard_Description = $item.description
        $tempWidget.Instance = $item.customer_id

        foreach($line in $section.Split("`r`n"))
        {
            if($line -like "description*")
            {
                $tempWidget.Widget_Description = $line.Replace("description       : ","")
            }
            if($line -like "query             :*")
            {
                $tempWidget.Widget_Query = $line.Replace("query             : ","")
            }
            if($line -like "title*")
            {
                $tempWidget.Widget_Title = $line.Replace("title             : ","")
            }
        }
        $allWidgets += $tempWidget
    }
}

$allWidgets | Export-Csv All_Dashboards_Refined.csv -NoTypeInformation

$refinedData = Import-Csv .\All_Dashboards_Refined.csv
$instanceData = Import-Csv .\instances.csv
foreach($item in $refinedData)
{
    foreach($line in $instanceData)
    {
        if($line.full_name -like "*$($item.Instance)*")
        {
            $item.Instance = $line.full_name
        }
    }
}

$refinedData | Export-Csv All_Dashboards_Refined.csv -NoTypeInformation