const { hashPassword } = require('../utils/hash'); // Import the hashPassword function

describe('Hash Password', () => {
  it('should return a hashed password', () => {
    const password = 'mysecurepassword'; // Sample input password
    const hashed = hashPassword(password); // Hash the password

    // Assert that the hashed password is not the same as the plain text password
    expect(hashed).not.toEqual(password);

    // Assert that the length of the hashed password matches bcrypt's hash length (60 characters)
    expect(hashed).toHaveLength(60);
  });
});
