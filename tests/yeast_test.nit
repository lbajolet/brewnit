import dummy_db

with ctx = new DBContext do
	var yeasts = ctx.yeast_worker.fetch_multiple(ctx, "* FROM yeasts")
	for i in yeasts do print i
end
