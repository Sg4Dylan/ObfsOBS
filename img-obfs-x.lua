obs = obslua

-- 注册滤镜
function script_description()
    return "A filter that randomly rearranges equal-sized rectangular segments of an image in X-axis."
end

-- Called on script startup
function script_load(settings)
    obs.obs_register_source(source_info)
end

-- 注册源
source_info = {}
source_info.id = "grid_shuffle_x_filter"
source_info.type = obs.OBS_SOURCE_TYPE_FILTER
source_info.output_flags = obs.OBS_SOURCE_VIDEO

-- 获取名称
source_info.get_name = function()
    return "Grid Shuffle X-Axis"
end

-- 创建滤镜
source_info.create = function(settings, source)
    local data = {}
    data.source = source
    data.width = 1
    data.width = 1

    -- 加载着色器文件
    obs.obs_enter_graphics()
    local effect_file_path = script_path() .. 'img-obfs-x.effect.hlsl'
    data.effect = obs.gs_effect_create_from_file(effect_file_path, nil)
    obs.obs_leave_graphics()

    -- Calls the destroy function if the effect was not compiled properly
    if data.effect == nil then
        obs.blog(obs.LOG_ERROR, "Effect compilation failed for " .. effect_file_path)
        source_info.destroy(data)
        return nil
    end

    -- Retrieves the shader uniform variables
    data.params = {}
    data.params.width = obs.gs_effect_get_param_by_name(data.effect, "width")
    data.params.height = obs.gs_effect_get_param_by_name(data.effect, "height")
    data.params.random_seed = obs.gs_effect_get_param_by_name(data.effect, "random_seed")
    data.params.grid_size = obs.gs_effect_get_param_by_name(data.effect, "grid_size")

    -- Calls update to initialize the rest of the properties-managed settings
    source_info.update(data, settings)

    return data
end

-- 销毁滤镜
source_info.destroy = function(data)
    if data.effect ~= nil then
        obs.obs_enter_graphics()
        obs.gs_effect_destroy(data.effect)
        data.effect = nil
        obs.obs_leave_graphics()
    end
end

-- Returns the width of the source
source_info.get_width = function(data)
  return data.width
end

-- Returns the height of the source
source_info.get_height = function(data)
  return data.height
end

-- 视频渲染
source_info.video_render = function(data)
    local parent = obs.obs_filter_get_parent(data.source)
    data.width = obs.obs_source_get_base_width(parent)
    data.height = obs.obs_source_get_base_height(parent)

    obs.obs_source_process_filter_begin(data.source, obs.GS_RGBA, obs.OBS_NO_DIRECT_RENDERING)

    -- Effect parameters initialization goes here
    obs.gs_effect_set_int(data.params.width, data.width)
    obs.gs_effect_set_int(data.params.height, data.height)
    obs.gs_effect_set_float(data.params.random_seed, data.random_seed)
    obs.gs_effect_set_int(data.params.grid_size, data.grid_size)

    obs.obs_source_process_filter_end(data.source, data.effect, data.width, data.height)
end

-- 获取默认设置
source_info.get_defaults = function(settings)
    obs.obs_data_set_default_double(settings, "random_seed", 42.0)
    obs.obs_data_set_default_int(settings, "grid_size", 24)
end

-- 获取属性
source_info.get_properties = function()
    local props = obs.obs_properties_create()

    obs.obs_properties_add_float_slider(props, "random_seed", "Random Seed", 1.0, 999999.0, 1.0)

    local grid_sizes = obs.obs_properties_add_list(props, "grid_size", "Tile Size",
        obs.OBS_COMBO_TYPE_LIST, obs.OBS_COMBO_FORMAT_INT)

    -- 添加可整除 GCD(1920x1080) 的选项
    -- 2, 3, 4, 5, 6, 8, 10, 12, 15, 20, 24, 30, 40, 60, 120
    obs.obs_property_list_add_int(grid_sizes, tostring(20), 20)
    obs.obs_property_list_add_int(grid_sizes, tostring(24), 24)
    obs.obs_property_list_add_int(grid_sizes, tostring(30), 30)
    obs.obs_property_list_add_int(grid_sizes, tostring(40), 40)
    obs.obs_property_list_add_int(grid_sizes, tostring(60), 60)
    obs.obs_property_list_add_int(grid_sizes, tostring(120), 120)

    return props
end

-- 更新设置
source_info.update = function(data, settings)
    data.random_seed = obs.obs_data_get_double(settings, "random_seed")
    data.grid_size = obs.obs_data_get_int(settings, "grid_size")
end
