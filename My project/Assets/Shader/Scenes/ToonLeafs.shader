Shader "Scene/ToonLeafs"
{
    Properties
    {
        _Color("Color", Color) = (0.5, 0.65, 1, 1)
        _Color2("Color2", Color) = (0.5, 0.65, 1, 1)
        [HDR]
        _AmbientColor("Ambient Color", Color) = (0.4,0.4,0.4,1)	
        _outlinecolor ("outline color", Color) = (0,0,0,1)
		_outlinewidth ("outline width", Range(0, 1)) = 0.01
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" }

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
                normal.z = -0.5;
                o.pos = UnityViewToClipPos(pos + float4(normalize(normal), 0) * _outlinewidth);
                
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                return fixed4(_outlinecolor.rgb,0);
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
            #include "Lighting.cginc"
            #include "AutoLight.cginc"
            #pragma multi_compile_fwdbase

            struct VertexInput
            {
                float4 vertex : POSITION;				
                float4 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct VertexOutput
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                SHADOW_COORDS(1)
            };
            
            VertexOutput vert (VertexInput v)
            {
                VertexOutput o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.normal = UnityObjectToWorldNormal(v.normal);
                TRANSFER_SHADOW(o)
                return o;
            }
            
            float4 _Color;
            float4 _Color2;
            float4 _AmbientColor;

            float4 frag (VertexOutput i) : SV_Target
            {
                float3 normal = normalize(i.normal);
                float nDotl = dot(_WorldSpaceLightPos0, normal);
                float shadow = SHADOW_ATTENUATION(i);
                float lightIntensity = smoothstep(0, 0.01, nDotl * shadow);
                float4 light = lightIntensity * _LightColor0;
                float4 col = lerp(_Color2, _Color * lightIntensity, nDotl * 0.5 + 0.5);

                return col * (_AmbientColor + light);
            }
            ENDCG
        }
    }
    Fallback "Diffuse"
}
