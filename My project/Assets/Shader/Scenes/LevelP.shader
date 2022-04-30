Shader "Scene/LevelP" 
{
    Properties {
        _BaseColor ("BaseColor", Color) = (0,0,0,1)
        _NormalMap ("NormalMap", 2D) = "bump" {}
        _outlinecolor ("outline color", Color) = (0,0,0,1)
        _outlinewidth ("outline width", Range(0, 1)) = 0.01
    }
    SubShader {
        Tags {
            "RenderType"="Opaque"
        }
        Pass {
            Name "Outline"
            Cull Front
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #pragma target 3.0
            
            float4 _outlinecolor;
            float _outlinewidth;
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
                // normal.z = -0.5;
                o.pos = UnityViewToClipPos(pos + float4(normalize(normal), 0) * _outlinewidth);
                
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                return fixed4(_outlinecolor.rgb,0);
            }
            ENDCG
        }
        Pass {
            Tags { "LightMode"="ForwardBase" }

            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase_fullshadows
            #pragma target 3.0

            sampler2D _NormalMap; float4 _NormalMap_ST;
            float4 _BaseColor;

            struct VertexInput {
                float4 vertex : POSITION;
                float2 uv0 : TEXCOORD0;
                float4 normal : NORMAL;
                float4 tangent : TANGENT;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float3 nDirWS : TEXCOORD1;
                float3 tDirWS : TEXCOORD2;
                float3 bDirWS : TEXCOORD3;
            };

            VertexOutput vert (VertexInput v) {
                VertexOutput o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv0 = v.uv0;
                o.nDirWS = UnityObjectToWorldNormal(v.normal);
                o.tDirWS = normalize(mul(unity_ObjectToWorld, float4(v.tangent.xyz, 0.0)).xyz);
                o.bDirWS = normalize(cross(o.nDirWS, o.tDirWS) * v.tangent.w);
                return o;
            }

            float4 frag(VertexOutput i) : COLOR {
                float3 var_NormalMap = UnpackNormal(tex2D(_NormalMap, i.uv0 * _NormalMap_ST)).rgb;
                float3x3 TBN = float3x3(i.tDirWS, i.bDirWS, i.nDirWS);
                float3 nDir = normalize(mul(var_NormalMap, TBN));
                float3 lDir = _WorldSpaceLightPos0.xyz;
                float nDotl = dot(nDir, lDir) * 0.5 + 0.5;
                float lambert = max(0.0, nDotl);
                return float4(lambert, lambert, lambert, 1.0) + _BaseColor;
            }

            ENDCG
        }
    }
    FallBack "Diffuse"
}
