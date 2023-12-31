/*******************************************************************************************************
 * This file is part of the Nebula Query & Search project, released under the MIT License.             *
 * See LICENSE file or go to https://github.com/jongpie/NebulaQueryAndSearch for full license details. *
 ******************************************************************************************************/

@SuppressWarnings(
  'PMD.ApexDoc, PMD.ApexAssertionsShouldIncludeMessage, PMD.ApexUnitTestClassShouldHaveAsserts, PMD.CyclomaticComplexity, PMD.EagerlyLoadedDescribeSObjectResult, PMD.ExcessiveParameterList, PMD.MethodNamingConventions, PMD.NcssMethodCount, PMD.UnusedLocalVariable'
)
@IsTest(IsParallel=true)
private class RecordSearch_Tests {
  @IsTest
  static void it_should_return_first_result_for_a_single_sobject_type() {
    String expectedSearchQueryString = 'FIND \'' + System.UserInfo.getUserEmail() + '\' IN ALL FIELDS RETURNING User(Id, Name)';

    Query userQuery = new Query(Schema.User.SObjectType);
    RecordSearch userSearch = new RecordSearch(System.UserInfo.getUserEmail(), userQuery);

    System.assertEquals(expectedSearchQueryString, userSearch.getSearch());
    User userSearchResult = (User) userSearch.getFirstResult();
  }

  @IsTest
  static void it_should_return_results_for_a_single_sobject_type() {
    String expectedSearchQueryString = 'FIND \'' + System.UserInfo.getUserEmail() + '\' IN ALL FIELDS RETURNING User(Id, Name)';

    Query userQuery = new Query(Schema.User.SObjectType);
    RecordSearch userSearch = new RecordSearch(System.UserInfo.getUserEmail(), userQuery);

    System.assertEquals(expectedSearchQueryString, userSearch.getSearch());
    List<User> userSearchResults = userSearch.getFirstResults();
  }

  @IsTest
  static void it_should_return_results_for_multiple_sobject_types() {
    String expectedSearchQueryString = 'FIND \'' + System.UserInfo.getUserEmail() + '\' IN ALL FIELDS RETURNING Account(Id, Name), User(Id, Name)';

    List<Query> queries = new List<Query>{ new Query(Schema.User.SObjectType), new Query(Schema.Account.SObjectType) };
    RecordSearch search = new RecordSearch(System.UserInfo.getUserEmail(), queries);

    System.assertEquals(expectedSearchQueryString, search.getSearch());
    List<List<SObject>> searchResults = search.getResults();
  }

  @IsTest
  static void it_should_return_results_with_highlight_enabled() {
    String expectedSearchQueryString = 'FIND \'' + System.UserInfo.getUserEmail() + '\' IN ALL FIELDS RETURNING User(Id, Name) WITH HIGHLIGHT';

    RecordSearch userSearch = new RecordSearch(System.UserInfo.getUserEmail(), new Query(Schema.User.SObjectType));
    userSearch.withHighlight();

    System.assertEquals(expectedSearchQueryString, userSearch.getSearch());
    List<User> userSearchResults = userSearch.getFirstResults();
  }

  @IsTest
  static void it_should_return_results_with_snippet_enabled() {
    Integer snippetTargetLength = 10;
    String expectedSearchQueryString =
      'FIND \'' +
      System.UserInfo.getUserEmail() +
      '\' IN ALL FIELDS RETURNING User(Id, Name)' +
      ' WITH SNIPPET (target_length=' +
      snippetTargetLength +
      ')';

    RecordSearch userSearch = new RecordSearch(System.UserInfo.getUserEmail(), new Query(Schema.User.SObjectType));
    userSearch.withSnippet(snippetTargetLength);

    System.assertEquals(expectedSearchQueryString, userSearch.getSearch());
    List<User> userSearchResults = userSearch.getFirstResults();
  }

  @IsTest
  static void it_should_return_results_in_email_search_group() {
    Integer snippetTargetLength = 10;
    String expectedSearchQueryString = 'FIND \'' + System.UserInfo.getUserEmail() + '\' IN EMAIL FIELDS RETURNING User(Id, Name)';

    RecordSearch userSearch = new RecordSearch(System.UserInfo.getUserEmail(), new Query(Schema.User.SObjectType));
    userSearch.inSearchGroup(SOSL.SearchGroup.EMAIL_FIELDS);

    System.assertEquals(expectedSearchQueryString, userSearch.getSearch());
    List<User> userSearchResults = (List<User>) userSearch.getFirstResults();
  }

  @IsTest
  static void it_should_return_results_with_spell_correction_enabled() {
    String expectedSearchQueryString = 'FIND \'' + System.UserInfo.getUserEmail() + '\' IN ALL FIELDS RETURNING User(Id, Name)' + ' WITH SPELL_CORRECTION = true';

    RecordSearch userSearch = new RecordSearch(System.UserInfo.getUserEmail(), new Query(Schema.User.SObjectType));
    userSearch.withSpellCorrection();

    System.assertEquals(expectedSearchQueryString, userSearch.getSearch());
    List<User> userSearchResults = userSearch.getFirstResults();
  }

  @IsTest
  static void it_should_return_results_with_update_article_reporting_for_tracking_enabled() {
    // If Knowledge isn't enabled, then we cannot use Knowledge-specific SOSL methods, so skip running this test
    if (!Schema.getGlobalDescribe().containsKey('KnowledgeArticle')) {
      return;
    }

    // If Knowledge is enabled, then execute the test
    String expectedSearchQueryString = 'FIND \'' + System.UserInfo.getUserEmail() + '\' IN ALL FIELDS RETURNING User(Id, Name)' + ' UPDATE TRACKING';

    RecordSearch userSearch = new RecordSearch(System.UserInfo.getUserEmail(), new Query(Schema.User.SObjectType));
    userSearch.updateArticleReporting(SOSL.ArticleReporting.TRACKING);

    System.assertEquals(expectedSearchQueryString, userSearch.getSearch());
    List<User> userSearchResults = userSearch.getFirstResults();
  }

  @IsTest
  static void it_should_return_results_with_update_article_reporting_for_viewstat_enabled() {
    // If Knowledge isn't enabled, then we cannot use Knowledge-specific SOSL methods, so skip running this test
    if (!Schema.getGlobalDescribe().containsKey('KnowledgeArticle')) {
      return;
    }

    // If Knowledge is enabled, then execute the test
    String expectedSearchQueryString = 'FIND \'' + System.UserInfo.getUserEmail() + '\' IN ALL FIELDS RETURNING User(Id, Name)' + ' UPDATE VIEWSTAT';

    RecordSearch userSearch = new RecordSearch(System.UserInfo.getUserEmail(), new Query(Schema.User.SObjectType));
    userSearch.updateArticleReporting(SOSL.ArticleReporting.VIEWSTAT);

    System.assertEquals(expectedSearchQueryString, userSearch.getSearch());
    List<User> userSearchResults = userSearch.getFirstResults();
  }

  @IsTest
  static void it_should_cache_search_results_when_enabled() {
    Integer loops = 4;
    Query userQuery = new Query(Schema.User.SObjectType);
    RecordSearch userSearch = new RecordSearch(System.UserInfo.getUserEmail(), userQuery);

    // First, verify that caching is not enabled by default
    System.assertEquals(0, System.Limits.getSoslQueries());
    for (Integer i = 0; i < loops; i++) {
      userSearch.getResults();
    }
    System.assertEquals(loops, System.Limits.getSoslQueries());

    System.Test.startTest();

    userSearch.cacheResults();
    for (Integer i = 0; i < loops; i++) {
      userSearch.getResults();
    }
    System.assertEquals(1, System.Limits.getSoslQueries());

    System.Test.stopTest();
  }
}
