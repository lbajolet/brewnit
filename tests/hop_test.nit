import dummy_db

with ctx = new DBContext do
	var res = ctx.hop_worker.fetch_multiple(ctx, "* FROM hops")
	for i in res do print i
end
