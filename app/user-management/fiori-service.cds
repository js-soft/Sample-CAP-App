using {UserService} from '../../srv/user-service';

annotate UserService.Users with @(
  UI: {
    HeaderInfo: {
      TypeName: '{i18n>User}',
      TypeNamePlural: '{i18n>Users}',
      Title: {
        Value: '{username}',
        Type: 'Text'
      },
      Description: {
        Value: '{firstName} {lastName} - {email}',
        Type: 'Text'
      }
    },
    CreationMode: {
      InitialData: {
        isActive: true,
        role: 'user'
      }
    },
    LineItem: [
      {
        $Type: 'UI.DataField',
        Value: username,
        Label: '{i18n>Username}'
      },
      {
        $Type: 'UI.DataField',
        Value: email,
        Label: '{i18n>Email}'
      },
      {
        $Type: 'UI.DataField',
        Value: firstName,
        Label: '{i18n>First Name}'
      },
      {
        $Type: 'UI.DataField',
        Value: lastName,
        Label: '{i18n>Last Name}'
      },
      {
        $Type: 'UI.DataField',
        Value: role,
        Label: '{i18n>Role}'
      },
      {
        $Type: 'UI.DataField',
        Value: isActive,
        Label: '{i18n>Active}'
      },
      {
        $Type: 'UI.DataField',
        Value: department,
        Label: '{i18n>Department}'
      }
    ],
    SelectionFields: [
      username,
      email,
      firstName,
      lastName,
      role,
      isActive,
      department
    ],
    Identification: [
      {
        $Type: 'UI.DataField',
        Value: username,
        Label: '{i18n>Username}'
      },
      {
        $Type: 'UI.DataField',
        Value: email,
        Label: '{i18n>Email}'
      }
    ],
    Facets: [
      {
        $Type: 'UI.ReferenceFacet',
        Target: '@UI.FieldGroup#UserInfo',
        Label: '{i18n>User Information}'
      }
    ],
    FieldGroup#UserInfo: {
      Data: [
        {
          $Type: 'UI.DataField',
          Value: username,
          Label: '{i18n>Username}'
        },
        {
          $Type: 'UI.DataField',
          Value: email,
          Label: '{i18n>Email}'
        },
        {
          $Type: 'UI.DataField',
          Value: firstName,
          Label: '{i18n>First Name}'
        },
        {
          $Type: 'UI.DataField',
          Value: lastName,
          Label: '{i18n>Last Name}'
        },
        {
          $Type: 'UI.DataField',
          Value: phone,
          Label: '{i18n>Phone}'
        },
        {
          $Type: 'UI.DataField',
          Value: department,
          Label: '{i18n>Department}'
        },
        {
          $Type: 'UI.DataField',
          Value: role,
          Label: '{i18n>Role}'
        },
        {
          $Type: 'UI.DataField',
          Value: password,
          Label: '{i18n>Password}'
        },
        {
          $Type: 'UI.DataField',
          Value: isActive,
          Label: '{i18n>Active}'
        }
      ]
    }
  }
);

// Add field-level annotations for better form handling
annotate UserService.Users with {
  username @(
    UI: {
      FieldGroup: #UserInfo,
      Identification: [{Value: username}],
      SelectionFields: [username]
    },
    Common: {
      Text: username
    }
  );
  email @(
    UI: {
      FieldGroup: #UserInfo,
      Identification: [{Value: email}],
      SelectionFields: [email]
    },
    Common: {
      Text: email
    }
  );
  firstName @(
    UI: {
      FieldGroup: #UserInfo,
      SelectionFields: [firstName]
    },
    Common: {
      Text: firstName
    }
  );
  lastName @(
    UI: {
      FieldGroup: #UserInfo,
      SelectionFields: [lastName]
    },
    Common: {
      Text: lastName
    }
  );
  phone @(
    UI: {
      FieldGroup: #UserInfo,
      SelectionFields: [phone]
    }
  );
  department @(
    UI: {
      FieldGroup: #UserInfo,
      SelectionFields: [department]
    }
  );
  role @(
    UI: {
      FieldGroup: #UserInfo,
      SelectionFields: [role]
    },
    Common: {
      ValueListWithFixedValues: true
    }
  );
  password @(
    UI: {
      FieldGroup: #UserInfo,
      SelectionFields: [password]
    }
  );
  isActive @(
    UI: {
      FieldGroup: #UserInfo,
      SelectionFields: [isActive]
    }
  );
  lastLogin @(
    UI: {
      FieldGroup: #UserInfo,
      SelectionFields: [lastLogin],
      Hidden: true
    }
  );
  passwordHash @UI.Hidden;
};

// Add value list for role field
annotate UserService.Users.role with @(
  Common: {
    ValueList: {
      CollectionPath: 'UserService.Roles'
    }
  }
);

annotate UserService.Users with @(
  Capabilities: {
    NavigationRestrictions: {
      NonNavigableProperties: [
        passwordHash
      ]
    }
  }
);

// Annotate actions for better UI integration
annotate UserService.activateUser with @(
  UI: {
    Action: {
      Label: '{i18n>Activate User}',
      Icon: 'sap-icon://activate'
    }
  }
);

annotate UserService.deactivateUser with @(
  UI: {
    Action: {
      Label: '{i18n>Deactivate User}',
      Icon: 'sap-icon://inactive'
    }
  }
);

annotate UserService.resetPassword with @(
  UI: {
    Action: {
      Label: '{i18n>Reset Password}',
      Icon: 'sap-icon://reset'
    }
  }
);

annotate UserService.changeUserRole with @(
  UI: {
    Action: {
      Label: '{i18n>Change Role}',
      Icon: 'sap-icon://role'
    }
  }
);

// Annotate Roles entity for value list
annotate UserService.Roles with @(
  UI: {
    LineItem: [
      {
        $Type: 'UI.DataField',
        Value: role,
        Label: '{i18n>Role}'
      },
      {
        $Type: 'UI.DataField',
        Value: description,
        Label: '{i18n>Description}'
      }
    ],
    Identification: [
      {
        $Type: 'UI.DataField',
        Value: role,
        Label: '{i18n>Role}'
      }
    ]
  },
  Common: {
    Text: description
  }
);
