$baseDir = "c:\src\K8sOps\02-Core-Workloads"
$outFile = "c:\src\K8sOps\plan_02.txt"

# Clear output
"" | Out-File $outFile -Encoding UTF8

# Sort modules as naturally as possible
$modules = Get-ChildItem -Path $baseDir -Directory | Where-Object { $_.Name -match "^2\.\d+-" }

# Define a custom sort value to sort 2.1, 2.2 ... 2.10, 2.11 properly
$modules = $modules | Sort-Object { [int]($_.Name -match "^2\.(\d+)-"; $matches[1]) }

$modIndex = 1
foreach ($mod in $modules) {
    # Calculate new module name
    $modName = $mod.Name -replace "^2\.\d+-", ""
    $newModName = "{0:D2}-$modName" -f $modIndex
    
    "MODULE: $($mod.Name) -> $newModName" | Out-File $outFile -Append -Encoding UTF8
    
    # Get all lesson dirs
    $lessonDirs = Get-ChildItem -Path $mod.FullName -Recurse -Directory | Where-Object { 
        $_.Name -match "^\d+\.\d+\.\d+.*" -and $_.Name -notmatch "^(scripts|yamls|lab-files)$" 
    }
    
    # Sort them by natural depth versioning
    # By split on dot, cast to int, etc.
    $lessonDirs = $lessonDirs | Sort-Object {
        $parts = $_.Name.Split("-")[0].Split(".")
        $val = 0
        if ($parts.Length -ge 1) { $val += [int]$parts[0] * 1000000 }
        if ($parts.Length -ge 2) { $val += [int]$parts[1] * 10000 }
        if ($parts.Length -ge 3) { $val += [int]$parts[2] * 100 }
        if ($parts.Length -ge 4) { $val += [int]$parts[3] * 1 }
        $val
    }
    
    $lesIndex = 1
    foreach ($les in $lessonDirs) {
        # Get purely the human name part
        $cleanName = $les.Name -replace '^\d+(\.\d+)+-', ''
        $newLesName = "{0:D2}-$cleanName" -f $lesIndex
        
        "  MOVE: $($les.FullName.Replace($baseDir, '')) -> \$newModName\$newLesName" | Out-File $outFile -Append -Encoding UTF8
        $lesIndex++
    }
    $modIndex++
}
