randomize();
surface_resize(application_surface, 1920, 1080);
perlin_noise_create_buffer("perlin_noise_buffer.dat");

instance_create_depth(0, 0, 0, MusicController);
instance_create_depth(0, 0, 0, PathfindingController);
instance_create_depth(0, 0, 0, NpcController);
instance_create_depth(0, 0, 0, FaxPileController);
instance_create_depth(0, 0, 0, TaskAssignmentController);

audio_group_load(ag_music);
audio_group_load(ag_sound);

room_goto_next();