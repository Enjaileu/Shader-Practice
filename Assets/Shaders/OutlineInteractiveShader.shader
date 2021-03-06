Shader "Outline Interactive Shader"
{
    Properties
    {
        _Color ("Main Color", Color) = (0,0,0,1)
        _MainTex ("Main Texture", 2D) = "white" {}
        _Outline("Outline width", float) = 0.1
        _OutlineColor("Outline color", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags 
        { 
            "Order"="Transparent"
            "RenderType" = "Transparent"
            "IgnoreProjector" = "True" 
        }

        // first = outline
        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            Cull front
            Zwrite off //desactiver zDepth donc normalement, va s'afficher derrière

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            uniform half _Outline;
            uniform half4 _OutlineColor;

            struct VertexInput
            {
                float4 vertex: POSITION;
            };

            struct VertexOutput
            {
                float4 pos: SV_POSITION;
            };

            float4 outline(float4 pos, float outline){
                float4x4 scale = 0.0;
                scale[0][0] = 1.0 + outline;
                scale[1][1] = 1.0 + outline;
                scale[2][2] = 1.0 + outline;
                scale[3][3] = 1.0;
                return mul(scale, pos);
            }

            VertexOutput vert(VertexInput v)
            {
                VertexOutput o;
                o.pos = UnityObjectToClipPos(outline(v.vertex, _Outline));
                return o;
            }

            half4 frag(VertexOutput i):COLOR 
            {
                return _OutlineColor;
            }
            ENDCG
        }

        //inside
        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            
            uniform half4 _Color;
            uniform sampler2D _MainTex;
            uniform float4 _MainTex_ST;

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

            VertexOutput vert(VertexInput v)
            {
                VertexOutput o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.texcoord.xy = (v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw);
                o.texcoord.zw = 0;
                return o;
            }

            half4 frag(VertexOutput i):COLOR 
            {
                return tex2D(_MainTex, i.texcoord)* _Color;
            }
            ENDCG
        }
    }
}
