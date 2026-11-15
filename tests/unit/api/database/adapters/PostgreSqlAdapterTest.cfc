<cfcomponent output="false" extends="mxunit.framework.TestCase">

	<cffunction name="test01_escapeEntity_shouldSurroundEntityInDoubleQuotes" returntype="void">
		<cfscript>
			var adapter  = _getAdapter();
			var expected = """myentity"""
			var result   = adapter.escapeEntity( "myEntity" );

			super.assertEquals( expected, result );
		</cfscript>
	</cffunction>

	<cffunction name="test01_1_escapeEntity_shouldEscapeEachPartOfDotDelimitedEntity" returntype="void">
		<cfscript>
			var adapter  = _getAdapter();
			var expected = """some_alias_perhaps"".""some_column"""
			var result   = adapter.escapeEntity( "some_alias_perhaps.some_column" );

			super.assertEquals( expected, result );
		</cfscript>
	</cffunction>

	<cffunction name="test02_getColumnDBType_shouldMapMediumtextToText" returntype="void">
		<cfscript>
			var adapter  = _getAdapter();
			var expected = "text";
			var result   = adapter.getColumnDBType( "mediumtext" );

			super.assertEquals( expected, result );
		</cfscript>
	</cffunction>

	<cffunction name="test02_1_getColumnDBType_shouldMapLongtextToText" returntype="void">
		<cfscript>
			var adapter  = _getAdapter();
			var expected = "text";
			var result   = adapter.getColumnDBType( "longtext" );

			super.assertEquals( expected, result );
		</cfscript>
	</cffunction>

	<cffunction name="test02_2_getColumnDBType_shouldMapTinyintToSmallint" returntype="void">
		<cfscript>
			var adapter  = _getAdapter();
			var expected = "smallint";
			var result   = adapter.getColumnDBType( "tinyint" );

			super.assertEquals( expected, result );
		</cfscript>
	</cffunction>

	<cffunction name="test03_getColumnDefinitionSql_shouldReturnPostgreSqlFormattedBasicColumnDefinition" returntype="void">
		<cfscript>
			var adapter  = _getAdapter();
			var expected = """mycolumn"" varchar(200) null";
			var result   = adapter.getColumnDefinitionSql(
				  columnName = "mycolumn"
				, dbType     = "varchar"
				, maxLength  = 200
				, nullable   = true
			);

			super.assertEquals( expected, result );
		</cfscript>
	</cffunction>

	<cffunction name="test03_1_getColumnDefinitionSql_shouldMapMediumtextToText" returntype="void">
		<cfscript>
			var adapter  = _getAdapter();
			var expected = """mycolumn"" text null";
			var result   = adapter.getColumnDefinitionSql(
				  columnName = "mycolumn"
				, dbType     = "mediumtext"
				, nullable   = true
			);

			super.assertEquals( expected, result );
		</cfscript>
	</cffunction>

	<cffunction name="test03_2_getColumnDefinitionSql_shouldMapTinyintToSmallint" returntype="void">
		<cfscript>
			var adapter  = _getAdapter();
			var expected = """mycolumn"" smallint not null";
			var result   = adapter.getColumnDefinitionSql(
				  columnName = "mycolumn"
				, dbType     = "tinyint"
				, nullable   = false
			);

			super.assertEquals( expected, result );
		</cfscript>
	</cffunction>

	<cffunction name="test04_getSelectSql_shouldStripQuotedAliasesInAutoGroupBy" returntype="void">
		<cfscript>
			var adapter  = _getAdapter();
			var result   = adapter.getSelectSql(
				  tableName     = "page"
				, selectColumns = [ "page._hierarchy_slug as ""full_slug""", "Count(*) as cnt" ]
			);

			super.assert( FindNoCase( "group by", result ), "Should include GROUP BY clause when aggregate functions are present" );
			super.assert( !FindNoCase( "as ""full_slug""", result ), "Should strip quoted alias from GROUP BY clause" );
		</cfscript>
	</cffunction>

	<cffunction name="test05_getSelectSql_shouldHandleUnquotedAliasesInAutoGroupBy" returntype="void">
		<cfscript>
			var adapter  = _getAdapter();
			var result   = adapter.getSelectSql(
				  tableName     = "test"
				, selectColumns = [ "test.col as myalias", "Sum(test.value) as total" ]
			);

			super.assert( FindNoCase( "group by", result ), "Should include GROUP BY clause when aggregate functions are present" );
			super.assert( !FindNoCase( "as myalias", result ), "Should strip unquoted alias from GROUP BY clause" );
		</cfscript>
	</cffunction>

	<cffunction name="test06_getInsertSql_shouldReturnReturningClause" returntype="void">
		<cfscript>
			var adapter  = _getAdapter();
			var expected = ["insert into ""event_category"" ( ""col_a"", ""col_b"" ) values ( :col_a, :col_b ) RETURNING *"];
			var result   = adapter.getInsertSql(
				  tableName     = "event_category"
				, insertColumns = [ "col_a", "col_b" ]
			);

			super.assertEquals( expected, result );
		</cfscript>
	</cffunction>

	<cffunction name="test07_supportsUpsertSql_shouldReturnTrue" returntype="void">
		<cfscript>
			var adapter = _getAdapter();
			super.assertTrue( adapter.supportsUpsertSql() );
		</cfscript>
	</cffunction>

	<cffunction name="test08_getUpsertSql_shouldReturnOnConflictSyntax" returntype="void">
		<cfscript>
			var adapter  = _getAdapter();
			var result   = adapter.getUpsertSql(
				  tableName       = "system_config"
				, insertColumns   = [ "category", "setting", "value", "tenant_id" ]
				, updateColumns   = [ "value" ]
				, conflictColumns = [ "category", "setting", "tenant_id" ]
			);

			super.assert( FindNoCase( "on conflict", result[1] ), "Should include ON CONFLICT clause" );
			super.assert( FindNoCase( "do update set", result[1] ), "Should include DO UPDATE SET clause" );
		</cfscript>
	</cffunction>

	<cffunction name="test09_sqlDataTypeToCfSqlDatatype_shouldReturnCfEquivalentForPostgreSqlDatatypes" returntype="void">
		<cfscript>
			var adapter = _getAdapter();
			var matrix  = {
				  cf_sql_bigint        = [ "bigint signed", "int unsigned", "bigint"                                             ]
				, cf_sql_integer       = [ "mediumint signed", "mediumint unsigned", "int signed", "mediumint", "int", "integer" ]
				, cf_sql_smallint      = [ "smallint signed", "smallint unsigned", "tinyint signed", "tinyint", "smallint"       ]
				, cf_sql_timestamp     = [ "datetime", "timestamp"                                                               ]
				, cf_sql_longvarchar   = [ "text", "mediumtext", "longtext"                                                      ]
			};
			var cfType    = "";
			var pgType    = "";
			var result    = "";

			for( cfType in matrix ){
				for( pgType in matrix[ cfType ] ) {
					result = adapter.sqlDataTypeToCfSqlDatatype( pgType );
					super.assertEquals( cfType, result, "Cf type for [#pgType#] should be [#cfType#]. [#result#] was returned instead" );
				}
			}
		</cfscript>
	</cffunction>

	<cffunction name="test10_getSelectSql_shouldUseLimitOffsetSyntax" returntype="void">
		<cfscript>
			var adapter  = _getAdapter();
			var expected = """id"" from ""event"" limit 10 offset 10";
			var result   = adapter.getSelectSql(
				  tableName     = "event"
				, selectColumns = [ "`id`" ]
				, maxRows       = 10
				, startRow      = 11
			);

			super.assert( FindNoCase( expected, result ), "Should use LIMIT OFFSET syntax" );
		</cfscript>
	</cffunction>

<!--- test helpers --->
	<cffunction name="_getAdapter" access="private" returntype="any" output="false">
		<cfscript>
			var mockedDbInfo = querySim( "database_productname,database_version
			    PostgreSQL | 18.0.0"
			);

			return new preside.system.services.database.adapters.PostgreSqlAdapter( dbInfo=mockedDbInfo, dsn="preside" );
		</cfscript>
	</cffunction>
</cfcomponent>
