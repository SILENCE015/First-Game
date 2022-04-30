Shader "Scene/ToonWater"
{
    Properties
    {
        _DepthGradientShallow("浅水颜色", Color) = (0.325, 0.807, 0.971, 0.725)
        _DepthGradientDeep("深水颜色", Color) = (0.086, 0.407, 1, 0.749)
        _DepthMaxDistance("最大深度", Float) = 1
        _SurfaceNoise("水波纹理", 2D) = "white" {}
        _SurfaceNoiseCutoff("水波大小", Range(0, 1)) = 0.777
        _SurfaceDistortion("失真纹理", 2D) = "white" {}
        _SurfaceDistortionAmount("扰动强度", Range(0, 1)) = 0.27
        _FoamDistance("岸边水波", Float) = 0.4
        _SurfaceNoiseScroll("水流方向", Vector) = (0.03, 0.03, 0, 0)
        _FoamMaxDistance("最大泡沫距离", Float) = 0.4
        _FoamMinDistance("最小泡沫距离", Float) = 0.04
        _FoamColor ("泡沫颜色", Color) = (1.0, 1.0, 1.0, 1.0)
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" }

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha 
            ZWrite Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"


            sampler2D _CameraDepthTexture;
            float4 _DepthGradientShallow;
            float4 _DepthGradientDeep;
            float _DepthMaxDistance;
            sampler2D _SurfaceNoise; float4 _SurfaceNoise_ST;
            float _SurfaceNoiseCutoff;
            float _FoamDistance;
            float2 _SurfaceNoiseScroll;
            sampler2D _SurfaceDistortion; float4 _SurfaceDistortion_ST;
            float _SurfaceDistortionAmount;
            sampler2D _CameraNormalsTexture;
            float _FoamMaxDistance;
            float _FoamMinDistance;
            float4 _FoamColor;


            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv0 : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
                float2 uv0 : TEXCOORD0;
                float2 uv1 : TEXCOORD1;
                float4 screenPosition : TEXCOORD2;
            };

            v2f vert (appdata v)
            {
                v2f o;

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = v.normal;
                o.uv0 = TRANSFORM_TEX(v.uv0, _SurfaceNoise);
                o.uv1 = TRANSFORM_TEX(v.uv0, _SurfaceDistortion);
                o.screenPosition = ComputeScreenPos(o.vertex);

                return o;
            }

            // 自定义混合方式
            float4 alphaBlend(float4 top, float4 bottom)
            {
                float3 color = (top.rgb * top.a) + (bottom.rgb * (1 - top.a));
                float alpha = top.a + bottom.a * (1 - top.a);

                return float4(color, alpha);
            }

            float4 frag (v2f i) : SV_Target
            {
                // 采样
                float2 distortSample = (tex2D(_SurfaceDistortion, i.uv1).xy * 2 - 1) * _SurfaceDistortionAmount;
                float2 noiseUV = float2(i.uv0.x + _Time.y * _SurfaceNoiseScroll.x + distortSample.x, i.uv0.y + _Time.y * _SurfaceNoiseScroll.y + distortSample.y);
                float surfaceNoiseSample = tex2D(_SurfaceNoise, noiseUV).r;
                // 采样深度纹理
                float existingDepth01 = tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(i.screenPosition)).r;   // 非线性
                float existingDepthLinear = LinearEyeDepth(existingDepth01);                                    // 转化为线性
                float waterDepth = i.screenPosition.w;                      // 水面深度
                float depthDifference = existingDepthLinear - waterDepth;   // 屏幕空间深度和水面深度插值
                // 水颜色
                float waterDepthDifference01 = saturate(depthDifference / _DepthMaxDistance);
                float4 waterColor = lerp(_DepthGradientShallow, _DepthGradientDeep, waterDepthDifference01);
                // 水波
                float3 existingNormal = tex2Dproj(_CameraNormalsTexture, UNITY_PROJ_COORD(i.screenPosition));
                float3 normalDot = saturate(dot(existingNormal, i.normal));
                float foamDistance = lerp(_FoamMaxDistance, _FoamMinDistance, normalDot);
                float foamDepthDifference01 = saturate(depthDifference / foamDistance);
                float surfaceNoiseCutoff = foamDepthDifference01 * _SurfaceNoiseCutoff;
                float surfaceNoise = surfaceNoiseSample > surfaceNoiseCutoff ? 1 : 0;       // 对nois截断
                float4 surfaceNoiseColor = _FoamColor;
                surfaceNoiseColor.a *= surfaceNoise;

                return alphaBlend(surfaceNoiseColor, waterColor);
            }
            ENDCG
        }
    }
}
