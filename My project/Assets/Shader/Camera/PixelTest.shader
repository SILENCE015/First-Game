Shader "Custom/PixelTest"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _PixelSize ("Pixel Size", Range(0,256)) = 64
    }
    SubShader {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always
        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            struct appdata {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };
            struct v2f {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };
            v2f vert (appdata v) {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }
            sampler2D _MainTex;
            float4 _MainTex_TexelSize;
            float _PixelSize;
            fixed4 frag (v2f i) : SV_Target {
                float2 interval = _PixelSize * _MainTex_TexelSize.xy;
                float2 th = i.uv / interval;    // 按interval划分中，属于第几个像素
                float2 th_int = th - frac(th);  // 去小数，让采样的第几个纹素整数化，这就是失真UV关键
                th_int *= interval;             // 再重新按第几个像素的uv坐标定位
                return tex2D(_MainTex, th_int);
            }
            ENDCG
        }
    }
}
