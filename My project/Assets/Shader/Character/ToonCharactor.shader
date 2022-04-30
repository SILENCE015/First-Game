Shader "Toon/ToonCharactor"
{
    Properties {
        _MainTex ("MainTex", 2D) = "white" {}
        _HatchTex ("HatchTex", 2D) = "bump" {}
        _BaseColor ("BaseColor", Color) = (0.2039216,0.5960785,0.3254902,1)
        _ShadowColor ("ShadowColor", Color) = (0.1490196,0.3490196,0.3686275,1)
        _LightColor ("LightColor", Color) = (0.8784314,0.8784314,0.8784314,1)
        _OutlineColor ("OutlineColor", Color) = (0,0,0,1)
        _OutlineWidth ("OutlineWidth", Range(0, 1)) = 0.01
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
        
        Pass {
            Name "Forward"
            Tags {
                "LightMode"="ForwardBase"
            }
            
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #pragma multi_compile_fwdbase_fullshadows
            #pragma target 3.0
            
            uniform sampler2D _HatchTex; uniform float4 _HatchTex_ST;
            uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
            float4 _BaseColor;
            float4 _ShadowColor;
            float4 _LightColor;

            struct VertexInput {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float4 posWS : TEXCOORD1;
                float3 nDir : TEXCOORD2;
                float2 screenUV : TEXCOORD3;
                LIGHTING_COORDS(4,5)
            };

            VertexOutput vert (VertexInput v) {
                VertexOutput o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv0 = v.uv;
                o.posWS = mul(unity_ObjectToWorld, v.vertex);
                o.nDir = UnityObjectToWorldNormal(v.normal);
                float3 posVS = UnityObjectToViewPos(v.vertex).xyz;
                float originDist = UnityObjectToViewPos(float3(0.0, 0.0, 0.0)).z;
                o.screenUV = posVS.xy / posVS.z;            // VS空间畸变校正
                o.screenUV *= originDist;                   // UV乘以深度，纹理大小按距离锁定
                o.screenUV = o.screenUV * _HatchTex_ST.xy - frac(_Time.x * _HatchTex_ST.zw);  // 启用屏幕纹理ST
                TRANSFER_VERTEX_TO_FRAGMENT(o)
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                float3 nDir = normalize(i.nDir);
                float3 lDir = normalize(_WorldSpaceLightPos0.xyz);
                float nDotl = dot(i.nDir,lDir);
                float shadow = SHADOW_ATTENUATION(i);
                // float nDotls = smoothstep(0, 0.5, nDotl * shadow); // 截断
                
                
                float4 _MainTex_var = tex2D(_MainTex, i.uv0);
                float4 _HatchTex_var = tex2D(_HatchTex,i.screenUV); // 纹理

                float3 hatch = lerp(_ShadowColor.rgb,_LightColor.rgb,step(_HatchTex_var.rgb,nDotl)); // 阴影线
                
                float3 baseColor = nDotl * _BaseColor.rgb * _MainTex_var.rgb;

                float3 finalColor = hatch + baseColor;
                return float4(finalColor,1);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
