/**
 * @feature webflow
 * @feature sites
 */
component {

	property name="sqlRunner" inject="SqlRunner";

	private function isEnabled() {
		return isFeatureEnabled( "sitetree" );
	}

	private void function run() {
		var dsn         = getPresideObject( "webflow_configuration" ).getDsn();
		var adapter     = getPresideObject( "webflow_configuration" ).getDbAdapter();
		var adapterName = ListLast( GetMetaData( adapter ).name, "." );

		if ( adapterName == "PostgreSqlAdapter" ) {
			sqlRunner.runSql(
				  dsn = dsn
				, sql = "
					DELETE FROM webflow_configuration_step
					WHERE id IN (
						SELECT wcs_old.id
						FROM webflow_configuration_step wcs_old
						INNER JOIN webflow_configuration_step wcs_new ON wcs_new.step_id = wcs_old.step_id
							AND wcs_new.site = wcs_old.site
							AND wcs_new.id != wcs_old.id
						INNER JOIN webflow_configuration wc_old ON wc_old.id = wcs_old.webflow
						INNER JOIN webflow_configuration wc_new ON wc_new.id = wcs_new.webflow
						WHERE wc_old.webflow_id = wc_new.webflow_id
						  AND wc_old.site != wcs_old.site
						  AND wc_new.site = wcs_new.site
					)
				"
			);

			sqlRunner.runSql(
				  dsn = dsn
				, sql = "
					UPDATE webflow_configuration_step wcs
					SET webflow = (
						SELECT wc_correct.id
						FROM webflow_configuration wc_current
						INNER JOIN webflow_configuration wc_correct ON wc_correct.webflow_id = wc_current.webflow_id
							AND wc_correct.site = wcs.site
							AND wc_correct.is_singleton = true
							AND wc_correct.instance_ref IS NULL
						WHERE wc_current.id = wcs.webflow
						  AND wc_current.site != wcs.site
						  AND wc_current.is_singleton = true
						  AND wc_current.instance_ref IS NULL
					)
					WHERE EXISTS (
						SELECT 1
						FROM webflow_configuration wc_current
						WHERE wc_current.id = wcs.webflow
						  AND wc_current.site != wcs.site
						  AND wc_current.is_singleton = true
						  AND wc_current.instance_ref IS NULL
					)
				"
			);
		} else if ( adapterName == "MsSqlAdapter" || adapterName == "MsSql2012Adapter" ) {
			sqlRunner.runSql(
				  dsn = dsn
				, sql = "
					DELETE FROM webflow_configuration_step
					WHERE id IN (
						SELECT wcs_old.id
						FROM webflow_configuration_step wcs_old
						INNER JOIN webflow_configuration_step wcs_new ON wcs_new.step_id = wcs_old.step_id
							AND wcs_new.site = wcs_old.site
							AND wcs_new.id != wcs_old.id
						INNER JOIN webflow_configuration wc_old ON wc_old.id = wcs_old.webflow
						INNER JOIN webflow_configuration wc_new ON wc_new.id = wcs_new.webflow
						WHERE wc_old.webflow_id = wc_new.webflow_id
						  AND wc_old.site != wcs_old.site
						  AND wc_new.site = wcs_new.site
					)
				"
			);

			sqlRunner.runSql(
				  dsn = dsn
				, sql = "
					UPDATE webflow_configuration_step wcs
					SET webflow = (
						SELECT wc_correct.id
						FROM webflow_configuration wc_current
						INNER JOIN webflow_configuration wc_correct ON wc_correct.webflow_id = wc_current.webflow_id
							AND wc_correct.site = wcs.site
							AND wc_correct.is_singleton = 1
							AND wc_correct.instance_ref IS NULL
						WHERE wc_current.id = wcs.webflow
						  AND wc_current.site != wcs.site
						  AND wc_current.is_singleton = 1
						  AND wc_current.instance_ref IS NULL
					)
					WHERE EXISTS (
						SELECT 1
						FROM webflow_configuration wc_current
						WHERE wc_current.id = wcs.webflow
						  AND wc_current.site != wcs.site
						  AND wc_current.is_singleton = 1
						  AND wc_current.instance_ref IS NULL
					)
				"
			);
		} else {
			sqlRunner.runSql(
				  dsn = dsn
				, sql = "
					DELETE wcs_old FROM webflow_configuration_step wcs_old
					INNER JOIN webflow_configuration_step wcs_new ON wcs_new.step_id = wcs_old.step_id
						AND wcs_new.site = wcs_old.site
						AND wcs_new.id != wcs_old.id
					INNER JOIN webflow_configuration wc_old ON wc_old.id = wcs_old.webflow
					INNER JOIN webflow_configuration wc_new ON wc_new.id = wcs_new.webflow
					WHERE wc_old.webflow_id = wc_new.webflow_id
					  AND wc_old.site != wcs_old.site
					  AND wc_new.site = wcs_new.site
				"
			);

			sqlRunner.runSql(
				  dsn = dsn
				, sql = "
					UPDATE webflow_configuration_step wcs
					INNER JOIN webflow_configuration wc_current ON wc_current.id = wcs.webflow
					INNER JOIN webflow_configuration wc_correct ON wc_correct.webflow_id = wc_current.webflow_id
						AND wc_correct.site = wcs.site
						AND wc_correct.is_singleton = 1
						AND wc_correct.instance_ref IS NULL
					SET wcs.webflow = wc_correct.id
					WHERE wc_current.site != wcs.site
					  AND wc_current.is_singleton = 1
					  AND wc_current.instance_ref IS NULL
				"
			);
		}
	}

}
