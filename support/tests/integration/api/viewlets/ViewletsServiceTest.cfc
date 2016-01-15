component extends="testbox.system.BaseSpec"{

	function run(){

		describe( "listPossibleViewlets()", function(){
			it( "should return an empty array when there are no configured directories", function(){
				var service = getService( directories=[] );

				expect( service.listPossibleViewlets() ).toBe( [] );
			} );

			it( "should return an array of dot notation viewlets based on the views contained within the source directories", function(){
				var service = getService( directories=[
					  "/resources/viewletsservice/justviews/folder1"
					, "/resources/viewletsservice/justviews/folder2"
				] );
				var viewlets = service.listPossibleViewlets();

				viewlets.sort( "textnocase" );

				expect( viewlets ).toBe( [
					  "anotherview"
					, "default"
					, "default.index"
					, "subfolder.secondlevel.test"
					, "subfolder.someview"
				] );
			} );

			it( "should not return viewlets in site template folders when the site template is not the current site template", function(){
				var service = getService( directories=[
					  "/resources/viewletsservice/justviews/folder1"
					, "/resources/viewletsservice/justviews/folder2"
					, "/resources/viewletsservice/justviews/site-templates/mytemplate"
				] );
				var viewlets = service.listPossibleViewlets();

				viewlets.sort( "textnocase" );

				expect( viewlets ).toBe( [
					  "anotherview"
					, "default"
					, "default.index"
					, "subfolder.secondlevel.test"
					, "subfolder.someview"
				] );
			} );

			it( "should return additional viewlets from site template folders when site template matches current active site template", function(){
				var service = getService( directories=[
					  "/resources/viewletsservice/justviews/folder1"
					, "/resources/viewletsservice/justviews/folder2"
					, "/resources/viewletsservice/justviews/site-templates/mytemplate"
				] );

				mockSiteService.$( "getActiveSiteTemplate", "mytemplate" );

				var viewlets = service.listPossibleViewlets();

				viewlets.sort( "textnocase" );

				expect( viewlets ).toBe( [
					  "anotherview"
					, "default"
					, "default.index"
					, "subfolder.secondlevel.test"
					, "subfolder.someview"
					, "templatespecific.test"
				] );
			} );
		} );

	}

	private function getService( array directories=[] ) {
		variables.mockSiteService = CreateEmptyMock( "preside.system.services.sitetree.SiteService" );
		var service = CreateMock( object=new preside.system.services.viewlets.ViewletsService(
			  sourceDirectories = arguments.directories
			, siteService       = mockSiteService
		) );

		mockSiteService.$( "getActiveSiteTemplate", "default" );

		return service;
	}

}