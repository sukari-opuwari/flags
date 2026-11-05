param([string]$BaseName='African_Flags_Lesson_Plan')
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
$source = Get-Content -LiteralPath "$PSScriptRoot\$BaseName.html" -Raw -Encoding UTF8
$body = ($source -split '<body>')[1] -replace '</body></html>',''
$paragraphs = New-Object System.Text.StringBuilder
$matches = [regex]::Matches($body,'<h1>(.*?)</h1>|<h2>(.*?)</h2>|<h3>(.*?)</h3>|<p(?: class="([^"]*)")?>(.*?)</p>|<li>(.*?)</li>','Singleline')
$page = 0
foreach($m in $matches){
 $style='Normal'; $content=''; $before=''
 if($m.Groups[1].Success){$page++; $content=$m.Groups[1].Value; $style='Title'; if($page -gt 1){$before='<w:pageBreakBefore/>'}}
 elseif($m.Groups[2].Success){$content=$m.Groups[2].Value; $style='Heading1'}
 elseif($m.Groups[3].Success){$content=$m.Groups[3].Value; $style='Heading2'}
 elseif($m.Groups[5].Success){if($m.Groups[4].Value -eq 'footer'){continue}; $content=$m.Groups[5].Value}
 else{$content='• '+$m.Groups[6].Value}
 $runs=New-Object System.Text.StringBuilder
 foreach($part in [regex]::Split($content,'(<b>.*?</b>)')){
  $bold=$part.StartsWith('<b>'); $plain=[System.Net.WebUtility]::HtmlDecode(($part -replace '<[^>]+>',''))
  $plain=[System.Security.SecurityElement]::Escape($plain)
  $rpr=if($bold){'<w:rPr><w:b/></w:rPr>'}else{''}
  [void]$runs.Append("<w:r>$rpr<w:t xml:space=`"preserve`">$plain</w:t></w:r>")
 }
 [void]$paragraphs.Append("<w:p><w:pPr><w:pStyle w:val=`"$style`"/>$before</w:pPr>$runs</w:p>")
}
$document='<?xml version="1.0" encoding="UTF-8" standalone="yes"?><w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"><w:body>'+$paragraphs.ToString()+'<w:sectPr><w:pgSz w:w="11906" w:h="16838"/><w:pgMar w:top="850" w:right="1020" w:bottom="850" w:left="1020"/></w:sectPr></w:body></w:document>'
$styles='<?xml version="1.0" encoding="UTF-8"?><w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"><w:docDefaults><w:rPrDefault><w:rPr><w:rFonts w:ascii="Arial" w:hAnsi="Arial"/><w:sz w:val="21"/><w:color w:val="000000"/></w:rPr></w:rPrDefault><w:pPrDefault><w:pPr><w:spacing w:after="90" w:line="270" w:lineRule="auto"/></w:pPr></w:pPrDefault></w:docDefaults><w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/></w:style><w:style w:type="paragraph" w:styleId="Title"><w:name w:val="Title"/><w:basedOn w:val="Normal"/><w:pPr><w:keepNext/><w:spacing w:before="0" w:after="160"/></w:pPr><w:rPr><w:b/><w:sz w:val="36"/><w:color w:val="000000"/></w:rPr></w:style><w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:pPr><w:keepNext/><w:spacing w:before="190" w:after="80"/></w:pPr><w:rPr><w:b/><w:sz w:val="27"/></w:rPr></w:style><w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:pPr><w:keepNext/><w:spacing w:before="170" w:after="60"/></w:pPr><w:rPr><w:b/><w:sz w:val="23"/></w:rPr></w:style></w:styles>'
$path="$PSScriptRoot\$BaseName.docx"
$zip=[System.IO.Compression.ZipFile]::Open($path,[System.IO.Compression.ZipArchiveMode]::Create)
$entries=@{
 '[Content_Types].xml'='<?xml version="1.0"?><Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types"><Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/><Default Extension="xml" ContentType="application/xml"/><Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/><Override PartName="/word/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"/></Types>'
 '_rels/.rels'='<?xml version="1.0"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/></Relationships>'
 'word/document.xml'=$document
 'word/styles.xml'=$styles
 'word/_rels/document.xml.rels'='<?xml version="1.0"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/></Relationships>'
}
foreach($key in $entries.Keys){$entry=$zip.CreateEntry($key); $writer=New-Object System.IO.StreamWriter($entry.Open(),(New-Object System.Text.UTF8Encoding($false))); $writer.Write($entries[$key]); $writer.Dispose()}
$zip.Dispose()
Write-Output $path
