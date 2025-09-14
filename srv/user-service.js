const cds = require('@sap/cds');
const crypto = require('crypto');

module.exports = class UserService extends cds.ApplicationService {
  init() {
    const { Users, UserProfiles } = this.entities;

    // Generate UUID for new users
    this.before('NEW', Users, async (req) => {
      if (!req.data.ID) {
        req.data.ID = cds.utils.uuid();
      }
      
      // For development simplicity, keep password as plain text
      // In production, you would hash it:
      // if (req.data.password) {
      //   req.data.passwordHash = await this.hashPassword(req.data.password);
      //   delete req.data.password; // Remove plain password
      // }
      
      // Set default values
      if (!req.data.role) {
        req.data.role = 'user'; // Default to user if not specified
      }
      if (req.data.isActive === undefined) {
        req.data.isActive = true;
      }
      
      // Do not set lastLogin during creation - it should only be set when user actually logs in
      delete req.data.lastLogin;
    });

    // For development simplicity, keep password as plain text during updates
    // In production, you would hash it:
    // this.before('UPDATE', Users, async (req) => {
    //   if (req.data.password) {
    //     req.data.passwordHash = await this.hashPassword(req.data.password);
    //     delete req.data.password; // Remove plain password
    //   }
    // });

    // Action: Activate User
    this.on('activateUser', async (req) => {
      const { userId } = req.data;
      
      await UPDATE(Users).set({ isActive: true }).where({ ID: userId });
      
      return true;
    });

    // Action: Deactivate User
    this.on('deactivateUser', async (req) => {
      const { userId } = req.data;
      
      await UPDATE(Users).set({ isActive: false }).where({ ID: userId });
      
      return true;
    });

    // Action: Reset Password
    this.on('resetPassword', async (req) => {
      const { userId } = req.data;
      
      // Generate temporary password
      const tempPassword = this.generateTempPassword();
      const hashedPassword = await this.hashPassword(tempPassword);
      
      await UPDATE(Users).set({ passwordHash: hashedPassword }).where({ ID: userId });
      
      return tempPassword; // Return temporary password for admin to share
    });

    // Action: Change User Role
    this.on('changeUserRole', async (req) => {
      const { userId, newRole } = req.data;
      
      // Validate role
      const validRoles = ['user', 'admin', 'manager'];
      if (!validRoles.includes(newRole)) {
        req.error(400, `Invalid role: ${newRole}. Valid roles are: ${validRoles.join(', ')}`);
      }
      
      await UPDATE(Users).set({ role: newRole }).where({ ID: userId });
      
      return true;
    });

    // Function: Get User by Email
    this.on('getUserByEmail', async (req) => {
      const { email } = req.data;
      
      const user = await SELECT.one.from(Users).where({ email });
      
      if (!user) {
        req.error(404, `User with email ${email} not found`);
      }
      
      return user;
    });

    // Function: Get User by Username
    this.on('getUserByUsername', async (req) => {
      const { username } = req.data;
      
      const user = await SELECT.one.from(Users).where({ username });
      
      if (!user) {
        req.error(404, `User with username ${username} not found`);
      }
      
      return user;
    });

    // Function: Get Active Users
    this.on('getActiveUsers', async (req) => {
      const users = await SELECT.from(Users).where({ isActive: true });
      return users;
    });

    // Function: Get User Statistics
    this.on('getUserStats', async (req) => {
      const totalUsers = await SELECT.one.from(Users).columns('count(*) as count');
      const activeUsers = await SELECT.one.from(Users).columns('count(*) as count').where({ isActive: true });
      const adminUsers = await SELECT.one.from(Users).columns('count(*) as count').where({ role: 'admin' });
      
      return {
        totalUsers: totalUsers.count,
        activeUsers: activeUsers.count,
        adminUsers: adminUsers.count
      };
    });

    // Update last login timestamp
    this.on('login', async (req) => {
      const { username } = req.data;
      
      await UPDATE(Users)
        .set({ lastLogin: new Date() })
        .where({ username });
    });

    return super.init();
  }

  // Helper method to hash passwords
  async hashPassword(password) {
    return new Promise((resolve, reject) => {
      crypto.pbkdf2(password, 'salt', 100000, 64, 'sha512', (err, derivedKey) => {
        if (err) reject(err);
        resolve(derivedKey.toString('hex'));
      });
    });
  }

  // Helper method to generate temporary password
  generateTempPassword() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*';
    let password = '';
    for (let i = 0; i < 12; i++) {
      password += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return password;
  }

  // Helper method to verify password
  async verifyPassword(password, hash) {
    const hashedPassword = await this.hashPassword(password);
    return hashedPassword === hash;
  }
};
