public with sharing class TestTGApex {   
    private static final String CLASS_NAME = 'TestTGApex';
	private static final String DEBUG = '[' + CLASS_NAME + '] ';	
	
    public static void Method1() {
        
        List<String> listStr = new List<String>();
        listStr.add('1');
        listStr.add('2');
        listStr.add('3');
        system.debug('listStr --' + listStr);
        Method2(listStr);
        system.debug('listStr2 --' + listStr);
        
    }
    public static void Method2(List<String> listStr2) {
        
        listStr2.add('4');
        
    }
}