public with sharing class UserService {

	public static User getUserById(Id userId) {
		User user = [SELECT Id
						, Name
						, CompanyName
						, Tax_Id__c
						, Address
						, Email
						, Phone
					FROM User 
					WHERE Id = :userId
					WITH SECURITY_ENFORCED
					LIMIT 1];
		return user;
	}
}