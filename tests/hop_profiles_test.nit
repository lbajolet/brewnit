import dummy_db

with ctx = new DBContext do
	var res = ctx.hop_profile_worker.fetch_multiple(ctx, "* FROM hop_profiles")
	for i in res do print i
end
