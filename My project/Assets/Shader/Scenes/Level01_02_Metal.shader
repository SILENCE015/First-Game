Shader "Unlit/Level01_02_Metal"
{
    Properties
    {
        _NormTex ("法线贴图", 2D) = "bump" {}
        _MainCol ("颜色", Color) = (0.5, 0.5, 0.5, 1.0)
        _EnvDiffInt ("漫反射强度", Range(0, 1)) = 0.2
        _SpecPow ("高光次幂", Range(1, 90)) = 30
        _SpecInt ("高光强度", Range(0, 5))  = 1
        _EnvSpecInt ("镜面反射强度", Range(0, 5)) = 0.2
        _FresnelPow ("菲涅尔次幂", Range(0, 5)) = 1
        _OutlineColor ("OutlineColor", Color) = (0,0,0,1)
        _OutlineWidth ("OutlineWidth", Range(0, 1)) = 0.01
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass {
            Name "Outline"
            Cull Front
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #pragma target 3.0
            
            float4 _OutlineColor;
            float _OutlineWidth;

            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
            };

            VertexOutput vert (VertexInput v) {
                VertexOutput o;

                float3 pos = UnityObjectToViewPos(v.vertex);
                float3 normal = mul((float3x3)UNITY_MATRIX_IT_MV, v.normal);  
                normal.z = -0.5;
                o.pos = UnityViewToClipPos(pos + float4(normalize(normal), 0) * _OutlineWidth);
                
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                return fixed4(_OutlineColor.rgb,0);
            }

            ENDCG
        }

        Pass
        {
            Tags { "LightMode"="ForwardBase" }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "Lighting.cginc"
            #pragma multi_compile_fwdbase_fullshadow
            #pragma target 3.0

            sampler2D _NormTex; float4 _NormTex_ST;
            float3 _MainCol;
            float _EnvDiffInt;
            float _SpecPow;
            float _SpecInt;
            float _FresnelPow;
            float _EnvSpecInt;

            struct VertexInput {
                float4 vertex : POSITION;   // 顶点信息
                float2 uv0 : TEXCOORD0;     // UV信息
                float4 normal : NORMAL;     // 法线信息
                float4 tangent : TANGENT;   // 切线信息
            };

            struct VertexOutput {
                float4 pos : SV_POSITION;   // 屏幕顶点位置
                float2 uv0 : TEXCOORD0;     // UV0
                float4 posWS : TEXCOORD1;   // 世界空间顶点位置
                float3 nDirWS : TEXCOORD2;  // 世界空间法线方向
                float3 tDirWS : TEXCOORD3;  // 世界空间切线方向
                float3 bDirWS : TEXCOORD4;  // 世界空间副切线方向
                LIGHTING_COORDS(5,6)       // 投影相关
            };

            VertexOutput vert (VertexInput v) {
                VertexOutput o;
                o.pos = UnityObjectToClipPos(v.vertex);         // 顶点位置 OS>CS
                o.uv0 = v.uv0;                                  // 传递UV
                o.posWS = mul(unity_ObjectToWorld, v.vertex);   // 顶点位置 OS>WS
                o.nDirWS = UnityObjectToWorldNormal(v.normal);  // 法线方向 OS>WS
                o.tDirWS = normalize(mul(unity_ObjectToWorld, float4(v.tangent.xyz, 0.0)).xyz); // 切线方向 OS>WS
                o.bDirWS = normalize(cross(o.nDirWS, o.tDirWS) * v.tangent.w);  // 副切线方向
                TRANSFER_VERTEX_TO_FRAGMENT(o)                  // 投影相关
                return o;                                       // 返回输出结构
            }

            float4 frag(VertexOutput i) : COLOR {
                // 准备向量
                float3 nDirTS = UnpackNormal(tex2D(_NormTex, i.uv0 * _NormTex_ST)).rgb;
                float3x3 TBN = float3x3(i.tDirWS, i.bDirWS, i.nDirWS);
                float3 nDirWS = normalize(mul(nDirTS, TBN));
                float3 vDirWS = normalize(_WorldSpaceCameraPos.xyz - i.posWS.xyz);
                float3 vrDirWS = reflect(-vDirWS, nDirWS);
                float3 lDirWS = _WorldSpaceLightPos0.xyz;
                float3 lrDirWS = reflect(-lDirWS, nDirWS);
                // 准备点积结果
                float ndotl = dot(nDirWS, lDirWS);
                float vdotr = dot(vDirWS, lrDirWS);
                float vdotn = dot(vDirWS, nDirWS);
                // 光照模型（直接光照部分）
                // 光源漫反射
                float3 baseCol = _MainCol;
                float lambert = max(0.0, ndotl);
                // 光源镜面反射
                float specCol = _MainCol;
                float specPow = lerp(1, _SpecPow, 1);
                float specInt = _SpecInt;
                float phong = pow(max(0.0, vdotr), specPow) * specInt;
                // 光源反射混合
                float shadow = LIGHT_ATTENUATION(i);
                float3 dirLighting = (baseCol * lambert + specCol * phong) * _LightColor0 * shadow;
                // 环境漫反射
                float3 envDiff = baseCol * _EnvDiffInt;
                // 环境镜面反射
                float fresnel = pow(max(0.0, 1.0 - vdotn), _FresnelPow); // 菲涅尔
                float3 envSpec = fresnel * _EnvSpecInt;
                // 返回结果
                float3 finalRGB = dirLighting;
                return float4(finalRGB, 1.0);
            }
            ENDCG
        }
    }
    Fallback "Diffuse"
}
