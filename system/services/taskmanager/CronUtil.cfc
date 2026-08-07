/**
 * Service providing cron parsing and other cron related utility functions.
 *
 * This is a thin Preside wrapper around the pure-CFML `chrono` library
 * (see /system/externals/chrono). It replaces the former cron-utils JAR /
 * OSGi dependency so that cron handling works on any CFML engine.
 *
 * @singleton      true
 * @presideService true
 */
component displayName="Cron util" {

// CONSTRUCTOR
	public any function init() {
		_setChrono( new chrono.models.Chrono() );

		return this;
	}

// PUBLIC API METHODS
	public string function validateExpression( required string crontabExpression ) {
		return _getChrono().validateExpression( argumentCollection=arguments );
	}

	public string function getNextRunDate( required string crontabExpression, date lastRun=Now() ) {
		return _getChrono().getNextRunDate( argumentCollection=arguments );
	}

	public string function describeCronTabExression( required string crontabExpression, required string locale ) {
		return _getChrono().describeCronTabExression( argumentCollection=arguments );
	}

// GETTERS AND SETTERS
	private any function _getChrono() {
		return _chrono;
	}
	private void function _setChrono( required any chrono ) {
		_chrono = arguments.chrono;
	}

}
