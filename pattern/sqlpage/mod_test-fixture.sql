CREATE TABLE IF NOT EXISTS "sqlpage_files" (
    "path" TEXT PRIMARY KEY NOT NULL,
    "contents" TEXT NOT NULL,
    "last_modified" DATE
)
INSERT INTO "sqlpage_files" ("path", "contents", "last_modified") VALUES ('index.sql', 'SELECT
  ''list'' as component,
  ''Get started: where to go from here ?'' as title,
  ''Here are some useful links to get you started with SQLPage.'' as description;
SELECT ''Information Schema (test)'' as title,
  ''info-schema.sql'' as link,
  ''TODO'' as description,
  ''blue'' as color,
  ''download'' as icon;', (CURRENT_TIMESTAMP)) ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP
INSERT INTO "sqlpage_files" ("path", "contents", "last_modified") VALUES ('info-schema.sql', '-- TODO: https://github.com/lovasoa/SQLpage/discussions/109#discussioncomment-7359513
--       see the above for how to fix for SQLPage but figure out to use the same SQL
--       in and out of SQLPage (maybe do what Ophir said in discussion and create
--       custom output for SQLPage using componetns?)
WITH TableInfo AS (
  SELECT
    m.tbl_name AS table_name,
    CASE WHEN c.pk THEN ''*'' ELSE '''' END AS is_primary_key,
    c.name AS column_name,
    c."type" AS column_type,
    CASE WHEN c."notnull" THEN ''*'' ELSE '''' END AS not_null,
    COALESCE(c.dflt_value, '''') AS default_value,
    COALESCE((SELECT pfkl."table" || ''.'' || pfkl."to" FROM pragma_foreign_key_list(m.tbl_name) AS pfkl WHERE pfkl."from" = c.name), '''') as fk_refs,
    ROW_NUMBER() OVER (PARTITION BY m.tbl_name ORDER BY c.cid) AS row_num
  FROM sqlite_master m JOIN pragma_table_info(m.tbl_name) c ON 1=1
  WHERE m.type = ''table''
  ORDER BY table_name, row_num
),
Views AS (
  SELECT ''## Views '' AS markdown_output
  UNION ALL
  SELECT ''| View | Column | Type |'' AS markdown_output
  UNION ALL
  SELECT ''| ---- | ------ |----- |'' AS markdown_output
  UNION ALL
  SELECT ''| '' || tbl_name || '' | '' || c.name || '' | '' || c."type" || '' | ''
  FROM
    sqlite_master m,
    pragma_table_info(m.tbl_name) c
  WHERE
    m.type = ''view''
),
Indexes AS (
  SELECT ''## Indexes'' AS markdown_output
  UNION ALL
  SELECT ''| Table | Index | Columns |'' AS markdown_output
  UNION ALL
  SELECT ''| ----- | ----- | ------- |'' AS markdown_output
  UNION ALL
  SELECT ''| '' ||  m.name || '' | '' || il.name || '' | '' || group_concat(ii.name, '', '') || '' |'' AS markdown_output
  FROM sqlite_master as m,
    pragma_index_list(m.name) AS il,
    pragma_index_info(il.name) AS ii
  WHERE
    m.type = ''table''
  GROUP BY
    m.name,
    il.name
)
SELECT
    markdown_output AS info_schema_markdown
FROM
  (
    SELECT ''## Tables'' AS markdown_output
    UNION ALL
    SELECT
      CASE WHEN ti.row_num = 1 THEN ''
### `'' || ti.table_name || ''` Table
| PK | Column | Type | Req? | Default | References |
| -- | ------ | ---- | ---- | ------- | ---------- |
'' ||
        ''| '' || is_primary_key || '' | '' || ti.column_name || '' | '' || ti.column_type || '' | '' || ti.not_null || '' | '' || ti.default_value || '' | '' || ti.fk_refs || '' |''
      ELSE
        ''| '' || is_primary_key || '' | '' || ti.column_name || '' | '' || ti.column_type || '' | '' || ti.not_null || '' | '' || ti.default_value || '' | '' || ti.fk_refs || '' |''
      END
    FROM TableInfo ti
    UNION ALL SELECT ''''
    UNION ALL SELECT * FROM	Views
    UNION ALL SELECT ''''
    UNION ALL SELECT * FROM Indexes
);

-- :info_schema_markdown should be defined in the above query
SELECT ''text'' as component,
       ''Information Schema'' as title,
       :info_schema_markdown as contents_md', (CURRENT_TIMESTAMP)) ON CONFLICT(path) DO UPDATE SET contents = EXCLUDED.contents, last_modified = CURRENT_TIMESTAMP