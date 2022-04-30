Shader "Scene/ToonScene"
{
	Properties
	{
		_Color("Color", Color) = (0.5, 0.65, 1, 1)
		_MainTex("Main Texture", 2D) = "white" {}
		[HDR]
		_AmbientColor("Ambient Color", Color) = (0.4,0.4,0.4,1)	
		[HDR]
		_SpecularColor("Specular Color", Color) = (0.9,0.9,0.9,1)
		_Glossiness("Glossiness", Float) = 32
		[HDR]
		_RimColor("Rim Color", Color) = (1,1,1,1)
		_RimAmount("Rim Amount", Range(0, 1)) = 0.716
		_RimThreshold("Rim Threshold", Range(0, 1)) = 0.1
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
				// normal.z = -0.5;
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
				float3 viewDir : TEXCOORD1;
				SHADOW_COORDS(2)
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _Color;
			float4 _AmbientColor;
			float _Glossiness;
			float4 _SpecularColor;
			float4 _RimColor;
			float _RimAmount;
			float _RimThreshold;
			
			VertexOutput vert (VertexInput v)
			{
				VertexOutput o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.normal = UnityObjectToWorldNormal(v.normal);
				o.viewDir = WorldSpaceViewDir(v.vertex);
				TRANSFER_SHADOW(o)
				return o;
			}

			float4 frag (VertexOutput i) : SV_Target
			{
				float4 sample = tex2D(_MainTex, i.uv);
				float3 normal = normalize(i.normal);
				float ndotl = dot(_WorldSpaceLightPos0, normal);
				float shadow = SHADOW_ATTENUATION(i);
				float lightIntensity = smoothstep(0, 0.01, ndotl * shadow);
				float4 light = lightIntensity * _LightColor0;
				float3 viewDir = normalize(i.viewDir);
				float3 halfVector = normalize(_WorldSpaceLightPos0 + viewDir);
				float ndoth = dot(normal, halfVector);
				float specularIntensity = pow(ndoth * lightIntensity, _Glossiness * _Glossiness);
				float specularIntensitySmooth = smoothstep(0.005, 0.01, specularIntensity);
				float4 specular = specularIntensitySmooth * _SpecularColor;

				return _Color * sample * (_AmbientColor + light + specular);
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
}
