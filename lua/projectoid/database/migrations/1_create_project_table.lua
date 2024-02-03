return {
  [[
    CREATE TABLE projects (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name VARCHAR(255) NOT NULL UNIQUE, 
      path VARCHAR(255) NOT NULL
    );
  ]],
}
