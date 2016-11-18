# Base for databse entities
module db_base

import sqlite3
import serialization
import console
import json::static
import json

# Context of the Database persistence layer
class DBContext
	super FinalizableOnce

	# A connection to a database
	var connection: Sqlite3DB is lazy do return new Sqlite3DB.open(database_name)

	redef fun finalize do connection.close

	# Name of the SQLite3 Database
	fun database_name: String do return "brewnit"

	# Use for logging of errors related to database statements
	fun log_sql_error(thrower: Object, query: Text) do
		print "Database error: '{connection.error or else "Unknown error"}' in class {thrower.class_name}".red
		print "Query was \"{query}\""
	end

	# Start property for `with` statements, empty since nothing needs to be done
	fun start do end

	# Finish property for `with` statements
	fun finish do connection.close

	# Try selecting data and log errors if there are some
	fun try_select(query: String): nullable Statement do
		var res = connection.select(query)
		if res == null then
			log_sql_error(self, query)
			return null
		end
		return res
	end
end

# A database entity
class Entity
	super Jsonable
	serialize

	# The database context `self` is linked to
	var context: nullable DBContext = null is noserialize, writable(set_context)

	# Attaches an entity to the database
	fun context=(ctx: DBContext) do set_context(ctx)

	# Commit the changes of `self` to database
	fun commit: Bool is abstract

	# Delete `self` from database
	fun delete: Bool is abstract

	# Inserts `self` into database
	fun insert: Bool is abstract

	# Updates `self` into database
	fun update: Bool is abstract

	# Basic template for inserting `self` to database
	protected fun basic_insert(query: String): Bool is abstract

	# Basic template for updating `self` in database
	protected fun basic_update(query: String): Bool is abstract

	# Basic template for deleting `self` in database
	protected fun basic_delete(query: String): Bool is abstract

	redef fun to_json do return serialize_to_json
end

# An entity with a single ID field
class UniqueEntity
	super Entity
	serialize

	# The identifier for `self` in database
	var id: Int = -1 is writable

	redef fun commit do
		if id == -1 then return insert
		return update
	end

	# Query used to attach context to an entity
	protected fun attach_query: String is abstract

	redef fun context=(ctx) do
		super
		var res = ctx.connection.select(attach_query)
		if res == null then
			ctx.log_sql_error(self, attach_query)
			return
		end
		for i in res do
			id = i.map["id"].as(Int)
			break
		end
	end

	redef fun basic_insert(q) do
		var ctx = context
		if ctx == null then return false
		var db = ctx.connection
		if not db.execute(q) then
			print "Unable to insert '{class_name}'"
			ctx.log_sql_error(self, q)
			return false
		end
		id = db.last_insert_rowid
		return true
	end

	redef fun basic_update(q) do
		var ctx = context
		if ctx == null then return false
		var db = ctx.connection
		if not db.execute(q) then
			print "Unable to update '{class_name}'"
			ctx.log_sql_error(self, q)
			return false
		end
		return true
	end

	redef fun basic_delete(q) do
		var ctx = context
		if ctx == null then return false
		var db = ctx.connection
		if not db.execute(q) then
			print "Unable to delete '{class_name}'"
			ctx.log_sql_error(self, q)
			return false
		end
		return true
	end
end
