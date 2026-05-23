# Script to patch flutter_secure_storage_windows plugin for ATL compatibility
# Run this script to patch the source file, then build

param(
    [string]$ProjectDir = $PSScriptRoot
)

# Find the plugin source in pub cache
$PluginSourceDir = "C:\Users\ACER\AppData\Local\Pub\Cache\hosted\pub.dev\flutter_secure_storage_windows-3.1.2\windows"
$CppFile = Join-Path $PluginSourceDir "flutter_secure_storage_windows_plugin.cpp"
$StubDir = Join-Path $PluginSourceDir "atl_stub"
$StubFile = Join-Path $StubDir "atlbase.h"

# Only proceed if files exist
if (-not (Test-Path $CppFile)) {
    Write-Host "Plugin source not found at: $CppFile"
    exit 1
}

Write-Host "Patching flutter_secure_storage_windows plugin..."

# Create ATL stub directory and file
if (-not (Test-Path $StubDir)) {
    New-Item -ItemType Directory -Path $StubDir -Force | Out-Null
}

# Write the ATL stub header
@"
#pragma once
// Minimal ATL stub to prevent C2872 ambiguous symbol errors for CW2A/CA2W
#ifndef _FLUTTER_ATL_STUB_ATLBASE_H_
#define _FLUTTER_ATL_STUB_ATLBASE_H_

#include <windows.h>
#include <string>
#include <vector>

// CA2W: ANSI to Wide conversion class
class CA2W {
public:
    wchar_t* m_psz;

    CA2W(LPCSTR psz, UINT nCodePage = CP_ACP) {
        if (!psz) { m_psz = nullptr; return; }
        int len = MultiByteToWideChar(nCodePage, 0, psz, -1, nullptr, 0);
        m_psz = new wchar_t[len > 0 ? len : 1];
        if (len > 0) MultiByteToWideChar(nCodePage, 0, psz, -1, m_psz, len);
    }

    ~CA2W() { delete[] m_psz; }
    CA2W(const CA2W&) = delete;
    CA2W& operator=(const CA2W&) = delete;
    operator LPCWSTR() const noexcept { return m_psz; }
    operator LPWSTR() const noexcept { return m_psz; }
};

// CW2A: Wide to ANSI conversion class
class CW2A {
public:
    std::string m_str;

    CW2A(LPCWSTR psz, UINT nCodePage = CP_ACP) {
        if (!psz) return;
        int len = WideCharToMultiByte(nCodePage, 0, psz, -1, nullptr, 0, nullptr, nullptr);
        if (len > 0) {
            std::vector<char> buf(static_cast<size_t>(len));
            WideCharToMultiByte(nCodePage, 0, psz, -1, buf.data(), len, nullptr, nullptr);
            m_str.assign(buf.data(), static_cast<size_t>(len - 1));
        }
    }

    operator const char*() const noexcept { return m_str.c_str(); }
    operator char*() const noexcept { return const_cast<char*>(m_str.c_str()); }
};

#endif // _FLUTTER_ATL_STUB_ATLBASE_H_
"@ | Out-File -FilePath $StubFile -Encoding UTF8

Write-Host "Created ATL stub at: $StubFile"

# Read the cpp file and add stub include if not present
$Content = Get-Content $CppFile -Raw

if ($Content -notmatch '#include\s+"atl_stub/atlbase.h"') {
    # Remove any existing ATL includes
    $Content = $Content -replace '#include\s+"atlbase\.h"\s*\n?', ''
    $Content = $Content -replace '#include\s+<atlstr\.h>\s*\n?', ''

    # Add our stub include at the very beginning
    $Content = '#include "atl_stub/atlbase.h"' + "`n" + $Content

    Set-Content -Path $CppFile -Value $Content -NoNewline
    Write-Host "Added ATL stub include to: $CppFile"
} else {
    Write-Host "ATL stub already included in: $CppFile"
}

Write-Host "Patch complete!"
