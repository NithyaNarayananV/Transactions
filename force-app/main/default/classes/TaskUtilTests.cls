@IsTest
private class TaskUtilTests {
  
  @IsTest
  static void testTaskPriorityNormal() {
    //GIVEN
    String state = 'NY';
    //WHEN
    Test.startTest();
    String priority = SampleClass4UnitTest.getTaskPriority(state);
    Test.stopTest();
    //THEN
    Assert.areEqual('Normal', priority);
  }
    @IsTest
  static void testTaskPriorityHigh() {
    //GIVEN
    String state = 'CA';
    //WHEN
    Test.startTest();
    String priority = SampleClass4UnitTest.getTaskPriority(state);
    Test.stopTest();
    //THEN
    Assert.areEqual('High', priority);
  } 
    @IsTest
  static void testTaskPriorityNull() {
    //GIVEN
    String state = 'CATD';
    //WHEN
    Test.startTest();
    String priority = SampleClass4UnitTest.getTaskPriority(state);
    Test.stopTest();
    //THEN
    Assert.areEqual(null, priority);
  }
}