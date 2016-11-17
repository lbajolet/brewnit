import dummy_db

with ctx = new DBContext do
	var res = ctx.fermentable_profile_worker.fetch_multiple(ctx, "* FROM fermentable_profiles")
	for i in res do print i
end
