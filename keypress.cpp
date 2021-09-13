#define WINVER 0x0500
#include <windows.h>
#include <iostream>
#include <string>
using namespace std;

int main(int argc, char** argv)
{
    // Scancodes: http://www.winfaq.de/faq_html/Content/tip1500/onlinefaq.php?h=tip1576.htm
    if (argc != 2) {
        return 1;
    }
    std::string slot = argv[1];
    int input = 0x01;
    if (slot.compare("1") == 0) { input = 0x3B; }
    if (slot.compare("2") == 0) { input = 0x3C; }
    if (slot.compare("3") == 0) { input = 0x3D; }
    if (slot.compare("4") == 0) { input = 0x3E; }
    if (slot.compare("5") == 0) { input = 0x3F; }
    if (slot.compare("6") == 0) { input = 0x40; }
    if (slot.compare("7") == 0) { input = 0x41; }
    if (slot.compare("8") == 0) { input = 0x42; }
    if (slot.compare("9") == 0) { input = 0x43; }
    if (slot.compare("10") == 0) { input = 0x44; }
    if (slot.compare("11") == 0) { input = 0x57; }
    if (slot.compare("12") == 0) { input = 0x58; }
    INPUT key;
    key.type = INPUT_KEYBOARD;
    key.ki.time = 0;
    key.ki.wVk = 0;
    key.ki.dwExtraInfo = 0;
    key.ki.dwFlags = KEYEVENTF_SCANCODE;
    key.ki.wScan = input; //0x42
    SendInput(1, &key, sizeof(INPUT));
    Sleep(250);
    key.ki.dwFlags = KEYEVENTF_SCANCODE | KEYEVENTF_KEYUP;
    SendInput(1, &key, sizeof(INPUT));
    return 0;
}
