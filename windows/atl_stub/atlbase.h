#pragma once
// Minimal ATL stub for builds without the Visual Studio ATL component.
// Provides only the symbols actually used by flutter_secure_storage_windows:
//   CA2W - ANSI -> Wide conversion (class with m_psz member + implicit LPCWSTR)
//   CW2A - Wide -> ANSI conversion (class with implicit const char* operator)
//
// IMPORTANT: The real ATL headers (atlstr.h / atlbase.h from the Windows SDK)
// are pulled in transitively via windows.h in the plugin.  This stub must
// define the same symbols so that the plugin code compiles without requiring
// the full ATL library.  Guard name is intentionally not __ATLBASE_H__ (the
// SDK's atlbase.h does not use that guard, so without a unique name the stub
// would be ignored and the real ATL would be included, causing CW2A/CA2W
// to become ambiguous — ATL defines them as both macros (atlstr.h) and classes
// (atlbase.h)).
#ifndef _FLUTTER_ATL_STUB_ATLBASE_H_
#define _FLUTTER_ATL_STUB_ATLBASE_H_

#include <windows.h>
#include <string>
#include <vector>

// ---------------------------------------------------------------------------
// CA2W: ANSI (char*) -> Wide (wchar_t*) conversion class.
// Matches the ATL interface: inherits from std::wstring and exposes m_psz.
// The m_psz member is used by the plugin for LPCWSTR-accepting Win32 APIs.
// ---------------------------------------------------------------------------
class CA2W : public std::wstring {
public:
  wchar_t* m_psz;

  CA2W(LPCSTR psz, UINT nCodePage = CP_ACP) : std::wstring() {
    if (!psz) {
      m_psz = nullptr;
      return;
    }
    int len = MultiByteToWideChar(nCodePage, 0, psz, -1, nullptr, 0);
    if (len > 0) {
      m_psz = new wchar_t[len];
      MultiByteToWideChar(nCodePage, 0, psz, -1, m_psz, len);
    } else {
      m_psz = nullptr;
    }
  }

  ~CA2W() { delete[] m_psz; }
  CA2W(const CA2W&) = delete;
  CA2W& operator=(const CA2W&) = delete;

  operator LPCWSTR() const noexcept { return m_psz; }
  operator LPWSTR() const noexcept { return m_psz; }
};

// ---------------------------------------------------------------------------
// CW2A: Wide (wchar_t*) -> ANSI (char*) conversion class.
// Matches the ATL interface: inherits from std::string and has implicit
// conversion operators so that:
//   std::string s = CW2A(wide);    -> implicit derived-to-base conversion
//   const char* p = CW2A(wide);    -> operator const char*()
// ---------------------------------------------------------------------------
class CW2A : public std::string {
public:
  CW2A(LPCWSTR psz, UINT nCodePage = CP_ACP) : std::string() {
    if (!psz) return;
    int len = WideCharToMultiByte(nCodePage, 0, psz, -1, nullptr, 0, nullptr, nullptr);
    if (len > 0) {
      std::vector<char> buf(static_cast<size_t>(len));
      WideCharToMultiByte(nCodePage, 0, psz, -1, buf.data(), len, nullptr, nullptr);
      // assign without the trailing null terminator
      assign(buf.data(), static_cast<size_t>(len - 1));
    }
  }

  operator const char*() const noexcept { return c_str(); }
  operator char*() const noexcept { return const_cast<char*>(c_str()); }
};

#endif  // _FLUTTER_ATL_STUB_ATLBASE_H_
