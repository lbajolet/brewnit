import dummy_db

with ctx = new DBContext do
	var res = ctx.fermentable_worker.fetch_multiple(ctx, "* FROM fermentables")
	for i in res do print i
end
