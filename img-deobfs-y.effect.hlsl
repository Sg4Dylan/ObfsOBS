// OBS-specific syntax adaptation to HLSL standard to avoid errors reported by the code editor
#define SamplerState sampler_state
#define Texture2D texture2d

// Uniform variables set by OBS (required)
uniform float4x4 ViewProj; // View-projection matrix used in the vertex shader
uniform Texture2D image;   // Texture containing the source picture

// General properties
uniform float random_seed = 42.0;
uniform int grid_size = 24.0;

// Size of the source picture
uniform int width;
uniform int height;

// Interpolation method and wrap mode for sampling a texture
SamplerState linear_clamp
{
	Filter    = Linear;     // Anisotropy / Point / Linear
	AddressU  = Clamp;      // Wrap / Clamp / Mirror / Border / MirrorOnce
	AddressV  = Clamp;      // Wrap / Clamp / Mirror / Border / MirrorOnce
	BorderColor = 00000000; // Used only with Border edges (optional)
};

// Data type of the input of the vertex shader
struct vertex_data
{
	float4 pos : POSITION;  // Homogeneous space coordinates XYZW
	float2 uv  : TEXCOORD0; // UV coordinates in the source picture
};

// Data type of the output returned by the vertex shader, and used as input
// for the pixel shader after interpolation for each pixel
struct pixel_data
{
	float4 pos : POSITION;  // Homogeneous screen coordinates XYZW
	float2 uv  : TEXCOORD0; // UV coordinates in the source picture
};

pixel_data VSDefault(vertex_data vertex)
{
	pixel_data pixel;
	pixel.pos = mul(float4(vertex.pos.xyz, 1.0), ViewProj);
	pixel.uv  = vertex.uv;
	return pixel;
}

// 伪随机函数
float random(float2 st, float gs) {
	return floor(fmod(fmod(123456789., random_seed * dot(st, float2(23.1406,2.6651))), gs));
}

float4 PSDefault(pixel_data pixel) : TARGET
{
	// 原始像素的坐标：U 为水平方向、V 为垂直方向，值域 (0, 1)
	float2 uv = pixel.uv;
	// 输入画布的大小，单位是 px
	float2 resolution = float2(width, height);
	// 格子数量
	float2 gridCount = resolution / grid_size;

	// 计算网格坐标
	float2 grid = floor(uv * resolution / grid_size);
	float2 gridUV = frac(uv * resolution / grid_size);

	// XY 偏移，单位是 Tile
	float y_random_offset = random(float2(1919.0, 810.0) + grid.x, gridCount.y);
	float y_offset = fmod(grid.y + gridCount.y - y_random_offset, gridCount.y);
	float2 xy_offset = float2(grid.x, y_offset);

	// 计算新的UV坐标
	float2 newUV = (xy_offset + gridUV) * grid_size / resolution;

	// 采样并返回颜色
	return image.Sample(linear_clamp, newUV);
}

technique Draw
{
	pass
	{
		vertex_shader = VSDefault(vertex);
		pixel_shader  = PSDefault(pixel);
	}
};
