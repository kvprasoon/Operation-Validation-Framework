$MyDir = [System.IO.Path]::GetDirectoryName($myInvocation.MyCommand.Definition)
$moduleDir = (resolve-path "$myDir/../..").path

Describe "OperationValidation Module Tests" {
    BeforeAll {
        $SavedModulePath = $env:PSModulePath
        if ( $env:psmodulepath.split(";") -notcontains $moduleDir )
        {
            $env:psmodulepath += ";$moduleDir"
        }
        Import-Module OperationValidation -Force
        $Commands = Get-Command -module OperationValidation|sort-object Name
    }
    AfterAll {
        $env:PSModulePath = $SavedModulePath
        remove-Module OperationValidation
    }
    It "Module has been loaded" {
        Get-Module OperationValidation | should not BeNullOrEmpty
    }
    Context "Exported Commands" {
        It "Exports 2 commands" {
            $commands.Count | Should be 2
        }
        It "The command names are correct" {
            $commands[0].Name | Should be "Get-OperationValidation"
            $commands[1].Name | Should be "Invoke-OperationValidation"
        }
    }
    Context "Get-OperationValidation parameters" {
        It "ModuleName parameter is proper type" {
            $commands[0].Parameters['ModuleName'].ParameterType | Should be ([System.String[]])
        }
        It "TestType parameter is proper type" {
            $commands[0].Parameters['TestType'].ParameterType | Should be ([System.String[]])
        }
        It "TestType parameter has proper constraints" {
            $Commands[0].Parameters['TestType'].Attributes.ValidValues.Count | should be 2
            $Commands[0].Parameters['TestType'].Attributes.ValidValues -eq "Simple" | Should be "Simple"
            $Commands[0].Parameters['TestType'].Attributes.ValidValues -eq "Comprehensive" | Should be "Comprehensive"
        }
    }
    Context "Invoke-OperationValidation parameters" {
        It "ModuleName parameter is proper type" {
            $commands[1].Parameters['ModuleName'].ParameterType | Should be ([System.String[]])
        }
        It "TestType parameter is proper type" {
            $commands[1].Parameters['TestType'].ParameterType | Should be ([System.String[]])
        }
        It "TestType parameter has proper constraints" {
            $Commands[1].Parameters['TestType'].Attributes.ValidValues.Count | should be 2
            $Commands[1].Parameters['TestType'].Attributes.ValidValues -eq "Simple" | Should be "Simple"
            $Commands[1].Parameters['TestType'].Attributes.ValidValues -eq "Comprehensive" | Should be "Comprehensive"
        }
    }
    Context "Get-OperationValidation finds proper tests" {
        It "Can find its own tests" {
            $tests = Get-OperationValidation -modulename OperationValidation
            $tests.Count | Should be 2
            $tests.File -eq "PSGallery.Simple.Tests.ps1" | Should be "PSGallery.Simple.Tests.ps1"
            $tests.File -eq "PSGallery.Comprehensive.Tests.ps1" | Should be "PSGallery.Comprehensive.Tests.ps1"
        }
        It "Can find tests which don't have an actual module" {
            $tests = Get-OperationValidation -moduleName Example.WindowsSearch
            @($tests).Count | Should be 1
            $tests.File | should be WindowsSearch.Simple.Tests.ps1
        }
        It "Formats the output appropriately" {
            $output = Get-OperationValidation -modulename OperationValidation | out-string -str -width 210|?{$_}
            $expected = ".*Module:   .*OperationValidation",
                        "Type:     Simple",
                        "File:     PSGallery.Simple.Tests.ps1",
                        "FilePath: .*PSGallery.Simple.Tests.ps1",
                        "Name:",
                        "Simple Validation of PSGallery",
                        ""
                        "Module:   .*OperationValidation",
                        "Type:     Comprehensive",
                        "File:     PSGallery.Comprehensive.Tests.ps1",
                        "FilePath: .*PSGallery.Comprehensive.Tests.ps1",
                        "Name:",
                        "E2E validation of PSGallery"
            for($i = 0; $i -lt $expected.Count;$i++)
            {
                $output[$i] | Should match $expected[$i]
            }
        }
    }
}
