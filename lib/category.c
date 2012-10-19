#include "category.h"
#include <stdlib.h>
#include <glib.h>

const char* cs[] = {
    "Games", 
    "Application",
    "Utility",
    "System",
    "Settings",
    "Office",
    "Network",
    "Development",
};

#define ARRAY_LEN(a) (sizeof(a)/sizeof(a[0]))

GHashTable* categorys[8] = { NULL };

const char** get_category_list()
{
    return cs;
}

void add_item_to_cateogry(const char* path, int cat_id)
{
    if (categorys[cat_id] == NULL) {
        categorys[cat_id] = g_hash_table_new_full(g_str_hash, g_str_equal, g_free, NULL);
    }
    GHashTable* c = categorys[cat_id];
    if (!g_hash_table_lookup(c, path)) {
        g_hash_table_insert(c, g_strdup(path), 1);
    }
}

char* get_categories()
{
    GString* string = g_string_new("[");
    for (int i=0; i< ARRAY_LEN(cs); i++) {
        g_string_append_printf(string, "{\"ID\":%d, \"Name\":\"%s\"},", i, cs[i]);
    }
    g_string_overwrite(string, string->len-1, "]");
    return g_string_free(string, FALSE);
}

char* get_deepin_categories(const char* path, const char** xdg_categories)
{
    GString* string = g_string_new("[");
    for (int i=0; i< 3; i++) {
        int c = rand() % ARRAY_LEN(cs);
        g_string_append_printf(string, "%d,", c);
        add_item_to_cateogry(path, c);
    }
    g_string_overwrite(string, string->len-1, "]");
    return g_string_free(string, FALSE);
}

void gen_item_info(char* path, GString* string)
{
    g_string_append_printf(string, "\"%s\",", path);
}

char* get_items_by_category(double _id)
{
    int id = (int)_id;
    g_assert(id < 8);
    GHashTable* c = categorys[id];
    if (c != NULL) {
        GList* items = g_hash_table_get_keys(c);
        GString *string = g_string_new("[");
        g_list_foreach(items, (GFunc)gen_item_info, string);
        g_string_overwrite(string, string->len-1, "]");
        g_list_free(items);
        return g_string_free(string, FALSE);
    } else {
        return g_strdup("[]");
    }
}
