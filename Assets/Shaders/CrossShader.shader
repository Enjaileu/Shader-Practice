Shader "Cross Shader"
{
    Properties
    {
        _Color ("Main Color", Color) = (1,1,1,1)
        _MainTex ("Main Texture", 2D) = "white" {}
        _Width ("Width", float) = 0.2
        _Start ("Start Line", float) = 0.4
    }
    SubShader
    {
        Tags 
        { 
            "Order"="Transparent"
            "RenderType" = "Transparent"
            "IgnoreProjector" = "True" 
        }

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            struct VertexInput
            {
                float4 vertex: POSITION;
                float4 texcoord: TEXCOORD0;
            };

            struct VertexOutput
            {
                float4 pos: SV_POSITION;
                float4 texcoord: TEXCOORD0;
            };

            uniform half4 _Color;
            uniform sampler2D _MainTex;
            uniform float4 _MainTex_ST;
            uniform float _Start;
            uniform float _Width;

            VertexOutput vert(VertexInput v)
            {
                VertexOutput o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.texcoord.xy = (v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw);
                o.texcoord.zw = 0;
                return o;
            }

            float drawLine(float2 uv, float start, float end)
            {
                if((uv.x > start && uv.x < end) || (uv.y > start && uv.y < end))
                {
                    return 1;
                }
                return 0;
            }
                

            half4 frag(VertexOutput i):COLOR 
            {
                float4 color = tex2D(_MainTex, i.texcoord)*_Color; // color contient la texture
                color.a = drawLine(i.texcoord.xy, _Start, _Start+_Width);
                return color;
                
            }
            ENDCG
        }
    }
}
