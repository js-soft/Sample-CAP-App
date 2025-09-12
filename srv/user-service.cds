using {sap.capire.bookshop as my} from '../db/schema';

service UserService @(requires: 'admin') {
  
  /** User Management - Admin Only */
  entity Users as projection on my.Users {
    *,
    // Include password field for development simplicity
    password,
    passwordHash
  };

  /** Public User Profile - Read Only */
  @readonly
  entity UserProfiles as projection on my.Users {
    ID,
    username,
    email,
    firstName,
    lastName,
    phone,
    department,
    role,
    isActive,
    lastLogin,
    profileImage
  };

  /** Actions for User Management */
  action activateUser(userId: Users:ID @mandatory) returns Boolean;
  action deactivateUser(userId: Users:ID @mandatory) returns Boolean;
  action resetPassword(userId: Users:ID @mandatory) returns String;
  action changeUserRole(userId: Users:ID @mandatory, newRole: String @mandatory) returns Boolean;

  /** Functions for User Management */
  function getUserByEmail(email: String @mandatory) returns Users;
  function getUserByUsername(username: String @mandatory) returns Users;
  function getActiveUsers() returns array of Users;
  function getUserStats() returns {
    totalUsers: Integer;
    activeUsers: Integer;
    adminUsers: Integer
  };

  /** Value List for Roles */
  @readonly
  entity Roles {
    key role: String(50);
        description: String(100);
  };
}

// Enable create functionality
annotate UserService.Users with @odata.draft.enabled;
