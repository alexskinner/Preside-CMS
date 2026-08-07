/**
 * @singleton
 *
 */
component {

// CONSTRUCTOR
	public any function init() {
		_setLibPath( ExpandPath( "/preside/system/services/security/antisamylib" ) );
		_setupPolicyFiles();
		_setupAntiSamy();

		return this;
	}

// PUBLIC API
	public any function clean( required string input, string policy="preside" ) {
		// RUSTCFML-NOOP: org.owasp.validator.html.AntiSamy is a JVM lib with no RustCFML
		// shim. When unavailable, pass the input through UNSANITIZED so rendering proceeds.
		// SECURITY: HTML/XSS sanitization is disabled while no-op'd — do not ship this to
		// production. See RustCFML/PRESIDE_BOOT_JAVA_NOOPS.md #5.
		if ( IsSimpleValue( _getAntiSamy() ) ) {
			return arguments.input;
		}

		var dirtyHtml      = ReplaceNoCase( arguments.input, "&quot;", "&~~~quot;", "all" );
		var antiSamyResult = _getAntiSamy().scan( dirtyHtml, _getPolicy( arguments.policy ) );
		var cleanHtml      = antiSamyResult.getCleanHtml();

		return _removeUnwantedCleanses( cleanHtml, arguments.policy );
	}

// PRIVATE HELPERS
	private void function _setupPolicyFiles() {
		var libPath = _getLibPath();

		_setPolicyFiles ( {
			  antisamy = libPath & '/antisamy-anythinggoes-1.4.4.xml'
			, ebay     = libPath & '/antisamy-ebay-1.4.4.xml'
			, myspace  = libPath & '/antisamy-myspace-1.4.4.xml'
			, slashdot = libPath & '/antisamy-slashdot-1.4.4.xml'
			, tinymce  = libPath & '/antisamy-tinymce-1.4.4.xml'
			, preside  = libPath & '/antisamy-preside-1.4.4.xml'
		} );
	}

	private void function _setupAntiSamy() {
		// RUSTCFML-NOOP: no JVM shim for AntiSamy — degrade so boot proceeds; clean() passes
		// input through unsanitized. See RustCFML/PRESIDE_BOOT_JAVA_NOOPS.md #5.
		try {
			_setAntiSamy( CreateObject( "java", "org.owasp.validator.html.AntiSamy", _listJars() ) );
		} catch ( any e ) {
			_setAntiSamy( "" );
		}
	}

	private any function _getPolicy( required string policy ) {
		_policies = _policies ?: {};

		if ( !StructKeyExists( _policies, arguments.policy ) ) {
			var policyFile    = _getPolicyFile( arguments.policy );
			var policyFactory = CreateObject( "java", "org.owasp.validator.html.Policy", _listJars() );

			_policies[ arguments.policy ] = policyFactory.getInstance( policyFile );
		}

		return _policies[ arguments.policy ];
	}

	private array function _listJars() {
		return DirectoryList( _getLibPath(), false, "path", "*.jar" );
	}

	private any function _getPolicyFile( required string policy ) {
		var policies = _getPolicyFiles();
		var filePath = policies[ arguments.policy ] ?: throw( type="preside.antisamyservice.policy.not.found", message="The policy [#arguments.policy#] was not found. Existing policies: '#SerializeJson( policies.keyArray() )#" );

		return CreateObject( "java", "java.io.File" ).init( filePath );
	}

	private string function _removeUnwantedCleanses( required string tooCleanString, required string policy ) {
		var antiSamyResult   = _getAntiSamy().scan( "&", _getPolicy( arguments.policy ) );
		var cleanedAmpersand = antiSamyResult.getCleanHtml();
		var uncleaned        = arguments.tooCleanString;

		if ( cleanedAmpersand != "&" ) {
			uncleaned = uncleaned.replace( cleanedAmpersand, "&", "all" );
		}

		uncleaned = ReplaceNoCase( uncleaned, "&quot;", """", "all" );
		uncleaned = ReplaceNoCase( uncleaned, "&~~~quot;", "&quot;", "all" );

		return uncleaned;
	}

// GETTERS AND SETTERS
	private string function _getLibPath() {
		return _libPath;
	}
	private void function _setLibPath( required string libPath ) {
		_libPath = arguments.libPath;
	}

	private struct function _getPolicyFiles() {
		return _policyFiles;
	}
	private void function _setPolicyFiles( required struct policyFiles ) {
		_policyFiles = arguments.policyFiles;
	}

	private any function _getAntiSamy() {
		return _antiSamy;
	}
	private void function _setAntiSamy( required any antiSamy ) {
		_antiSamy = arguments.antiSamy;
	}
}