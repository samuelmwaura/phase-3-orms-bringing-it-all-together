class Dog

     attr_accessor :name, :breed,:id

    def initialize(name:, breed:,id:nil)
        @id = id
        @name = name
        @breed= breed
    end

    #create the dog table
    def self.create_table
     sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs(
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
    )
     SQL

     DB[:conn].execute(sql)
    end
   
    #delete the dogs table from the db
    def self.drop_table
    sql= <<-SQL
         DROP TABLE dogs
        SQL

    DB[:conn].execute(sql)
    end

    #save a dog instance to the db
    def save
     sql=<<-SQL
     INSERT INTO dogs (name,breed) VALUES (?,?)
     SQL

     DB[:conn].execute(sql,self.name,self.breed)  #saves the instance to db
     self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]  #retrieve the saved identifier and assigning it to the intance attribute

     self  #this return instance is update with the saved id
    end
   
  #combiner method for creating a dog and saving it to the db
    def self.create(name:, breed:)
      dog = self.new(name:name,breed:breed) #help create a new dog instance
      dog.save #the instance is then saved to the db
    end
    
    #map a given returned row to an object
    def self.new_from_db(table_row)
        self.new(id:table_row[0],name:table_row[1],breed:table_row[2]) # creates an object/class instance from fetched data
    end

    #fetch all dogs from db
    def self.all
        sql = <<-SQL
        SELECT * FROM dogs
        SQL
         
        DB[:conn].execute(sql).map do |dog|
         self.new_from_db(dog)
        end
    end

    def self.find_by_name(name)
        sql = <<-SQL
        SELECT * FROM dogs WHERE name =? 
        LIMIT 1
        SQL

        DB[:conn].execute(sql,name).map do |dog|
            self.new_from_db(dog)  #convert the return result to an instance
       end.first #just return the first element of the array
   end


   #fetch a single dog from the db using an id
    def self.find(id)
        sql = <<-SQL
        SELECT * FROM dogs WHERE id=?
        LIMIT 1
        SQL

        DB[:conn].execute(sql,id).map do |dog|
            self.new_from_db(dog)
        end.first
    end
end
