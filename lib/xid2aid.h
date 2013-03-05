#ifndef _XID2AID_H__
#define _XID2AID_H__
#include <glib.h>

enum APPID_FINDER_FILTER {
    APPID_FILTER_ARGS=1,
    APPID_FILTER_WMCLASS,
    APPID_FILTER_WMINSTANCE,
    APPID_FILTER_WMNAME,
};

enum APPID_ICON_OPERATOR {
    ICON_OPERATOR_USE_RUNTIME=0,
    ICON_OPERATOR_USE_ICONNAME=1,
    ICON_OPERATOR_USE_PATH=2,
    ICON_OPERATOR_SET_DOMINANTCOLOR=3
};

char* find_app_id(const char* exec_name, const char* key, int filter);
void get_pid_info(int pid, char** exec_name, char** exec_args);
char* get_exe(const char* app_id, int pid);
gboolean is_app_in_white_list(const char* name);

gboolean is_deepin_app_id(const char* app_id);
int get_deepin_app_id_operator(const char* app_id);
char* get_deepin_app_id_value(const char* app_id);

#endif
