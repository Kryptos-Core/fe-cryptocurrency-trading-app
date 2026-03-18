#pragma once
// Minimal ATL stub for builds without the Visual Studio ATL component.
// Provides only the symbols actually used by flutter_local_notifications_windows:
//   CW2A(LPCWSTR, UINT) - wide-to-ANSI conversion class.
#ifndef __ATLBASE_H__
#define __ATLBASE_H__

#include <windows.h>
#include <string>
#include <vector>

// CW2A inherits std::string so that:
//   string(CW2A(wide, CP_UTF8))  -> std::string copy-ctor from base ✓
//   std::string s = CW2A(wide);  -> implicit derived-to-base conversion ✓
//   const char* p = CW2A(wide);  -> operator const char*() ✓
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

#endif  // __ATLBASE_H__
