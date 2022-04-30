// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "WRL/ParallaxOffset"
{
	Properties
	{
		_MainTexture("视差纹理", 2D) = "white" {}
		_Color("折射颜色", Color) = (1,1,1,0)
		_shendu1("深度1", Float) = 0
		_shendu1Speed("深度1速度", Range(0, 0.1)) = 0
		_shendu2("深度2", Float) = 0
		_shendu2Speed("深度2速度", Range(0, 0.1)) = 0
		_Alpha("Alpha", Range( 0 , 1)) = 0.5
		_NormalTexture("屏幕扰动纹理", 2D) = "bump" {}
		_NormalSpeedX("屏幕扰动速度X", Float) = 0
		_NormalSpeedY("屏幕扰动速度Y", Float) = 0
		_NormalScale("屏幕扰动强度", Float) = 0
		[HDR]_FresnelColor("边缘光颜色", Color) = (0,0,0,0)
		_Fresnel("边缘光设置", Vector) = (0,0,0,0)
		_NoiseTexture("扰动纹理", 2D) = "white" {}
		_NoiseSpeedX("扰动X速度", Float) = 0
		_NoiseSpeedY("扰动Y速度", Float) = 0

	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Transparent" "Queue"="Geometry" }
	LOD 100

		CGINCLUDE
		#pragma target 3.0
		ENDCG
		Blend SrcAlpha OneMinusSrcAlpha
		AlphaToMask Off
		Cull Back
		ColorMask RGBA
		ZWrite On
		ZTest LEqual
		Offset 0 , 0
		
		
		GrabPass{ }

		Pass
		{
			Name "Unlit"
			Tags { "LightMode"="ForwardBase" }
			CGPROGRAM

			#if defined(UNITY_STEREO_INSTANCING_ENABLED) || defined(UNITY_STEREO_MULTIVIEW_ENABLED)
			#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex);
			#else
			#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex)
			#endif


			#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
			//only defining to not throw compilation error over Unity 5.5
			#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
			#endif
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"
			#include "UnityShaderVariables.cginc"
			#include "UnityStandardUtils.cginc"
			#include "UnityStandardBRDF.cginc"
			#define ASE_NEEDS_FRAG_WORLD_POSITION


			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_tangent : TANGENT;
				float3 ase_normal : NORMAL;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 worldPos : TEXCOORD0;
				#endif
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform float4 _Color;
			ASE_DECLARE_SCREENSPACE_TEXTURE( _GrabTexture )
			uniform sampler2D _NormalTexture;
			uniform float _NormalSpeedX;
			uniform float _NormalSpeedY;
			uniform float4 _NormalTexture_ST;
			uniform float _NormalScale;
			uniform sampler2D _MainTexture;
			uniform float4 _MainTexture_ST;
			uniform float _shendu1;
			uniform float _shendu1Speed;
			uniform float _shendu2;
			uniform float _shendu2Speed;
			uniform float4 _Fresnel;
			uniform float4 _FresnelColor;
			uniform sampler2D _NoiseTexture;
			uniform float _NoiseSpeedX;
			uniform float _NoiseSpeedY;
			uniform float4 _NoiseTexture_ST;
			uniform float _Alpha;

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float4 ase_clipPos = UnityObjectToClipPos(v.vertex);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord1 = screenPos;
				float3 ase_worldTangent = UnityObjectToWorldDir(v.ase_tangent);
				o.ase_texcoord3.xyz = ase_worldTangent;
				float3 ase_worldNormal = UnityObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord4.xyz = ase_worldNormal;
				float ase_vertexTangentSign = v.ase_tangent.w * unity_WorldTransformParams.w;
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				o.ase_texcoord5.xyz = ase_worldBitangent;
				
				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.zw = 0;
				o.ase_texcoord3.w = 0;
				o.ase_texcoord4.w = 0;
				o.ase_texcoord5.w = 0;
				float3 vertexValue = float3(0, 0, 0);
				#if ASE_ABSOLUTE_VERTEX_POS
				vertexValue = v.vertex.xyz;
				#endif
				vertexValue = vertexValue;
				#if ASE_ABSOLUTE_VERTEX_POS
				v.vertex.xyz = vertexValue;
				#else
				v.vertex.xyz += vertexValue;
				#endif
				o.vertex = UnityObjectToClipPos(v.vertex);

				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				#endif
				return o;
			}
			
			fixed4 frag (v2f i ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
				// fixed4 finalColor;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 WorldPosition = i.worldPos;
				#endif
				float4 screenPos = i.ase_texcoord1;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float2 appendResult119 = (float2(_NormalSpeedX , _NormalSpeedY));
				float2 uv_NormalTexture = i.ase_texcoord2.xy * _NormalTexture_ST.xy + _NormalTexture_ST.zw;
				float2 panner117 = ( 1.0 * _Time.y * appendResult119 + uv_NormalTexture);
				float4 screenColor210 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,( ase_screenPosNorm + float4( UnpackScaleNormal( tex2D( _NormalTexture, panner117 ), _NormalScale ) , 0.0 ) ).xy);
				float2 uv_MainTexture = i.ase_texcoord2.xy * _MainTexture_ST.xy + _MainTexture_ST.zw;
				float3 ase_worldTangent = i.ase_texcoord3.xyz;
				float3 ase_worldNormal = i.ase_texcoord4.xyz;
				float3 ase_worldBitangent = i.ase_texcoord5.xyz;
				float3 tanToWorld0 = float3( ase_worldTangent.x, ase_worldBitangent.x, ase_worldNormal.x );
				float3 tanToWorld1 = float3( ase_worldTangent.y, ase_worldBitangent.y, ase_worldNormal.y );
				float3 tanToWorld2 = float3( ase_worldTangent.z, ase_worldBitangent.z, ase_worldNormal.z );
				float3 ase_worldViewDir = UnityWorldSpaceViewDir(WorldPosition);
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 ase_tanViewDir =  tanToWorld0 * ase_worldViewDir.x + tanToWorld1 * ase_worldViewDir.y  + tanToWorld2 * ase_worldViewDir.z;
				ase_tanViewDir = Unity_SafeNormalize( ase_tanViewDir );
				float2 Offset189 = ( ( _shendu1 - 1 ) * ase_tanViewDir.xy * 1.0 ) + uv_MainTexture;
				
				
				float2 Offset195 = ( ( _shendu2 - 1 ) * ase_tanViewDir.xy * 1.0 ) + uv_MainTexture;
				float fresnelNdotV203 = dot( ase_worldNormal, ase_worldViewDir );
				float fresnelNode203 = ( _Fresnel.x + _Fresnel.y * pow( max( 1.0 - fresnelNdotV203 , 0.0001 ), _Fresnel.z ) );
				float2 appendResult16 = (float2(_NoiseSpeedX , _NoiseSpeedY));
				float2 uv_NoiseTexture = i.ase_texcoord2.xy * _NoiseTexture_ST.xy + _NoiseTexture_ST.zw;
				float2 panner20 = ( 1.0 * _Time.y * appendResult16 + uv_NoiseTexture);
				float4 finalColor = (float4((( ( _Color * screenColor210 ) + tex2D( _MainTexture, ( Offset189 + ( _Time.y * _shendu1Speed ) ) ) + tex2D( _MainTexture, ( Offset195 + ( _Time.y * _shendu2Speed ) ) ) + ( saturate( fresnelNode203 ) * _FresnelColor * tex2D( _NoiseTexture, panner20 ).r ) )).rgb , _Alpha));
				
				
				// finalColor = appendResult214;
				return finalColor;
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
}