randomize();
surface_resize(application_surface, 1920, 1080);
perlin_noise_create_buffer("perlin_noise_buffer.dat");

audio_group_load(ag_music);
audio_group_load(ag_sound);

click_count = 0;