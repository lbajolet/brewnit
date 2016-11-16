import dummy_db

with ctx = new DBContext do
	var res = ctx.recipe_worker.fetch_multiple(ctx, "* FROM recipes")
	for i in res do print i
end
