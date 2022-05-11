Shader "Custom/surface"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Metallic("Metalic", Range(0, 1)) = 0
        _Smoothness ("Smoothness", Range(0, 1)) = 0.5
        _BumpMap ("Normalmap", 2d) = "bump" {} // 유니티는 인터페이스로부터 입력받는 변수명을 '_BumpMap' 이라고 지으면, 텍스쳐 인터페이스는 노말맵을 넣을 것이라고 인지함. 그래서 노말맵 텍스쳐를 입력하지 않을거면 다른 일반 인터페이스를 쓰라고 경고메시지를 띄움.
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard

        sampler2D _MainTex;
        sampler2D _BumpMap;
        float _Metallic;
        float _Smoothness;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_BumpMap;
        };

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
            
            /*
                노말맵 텍스쳐를 유니티에서 Texture Type 을 노말맵으로 변경해주면,
                해당 텍스쳐가 DXTnm 파일 형식으로 변환됨.

                이 형식은 현재의 노말맵의 R, G 값을 최대한 보전하여
                각각 A, G 값에 넣어서 저장한 형식임.

                이제 이 A, G 값을 X, Y로 계산하고, Z값을 삼각함수로 추출하는데,
                이러한 계산을 대신 해주는 유니티 쉐이더 스크립트 함수가
                UnpackNormal() 이라고 보면 됨.

                UnpackNormal() 함수는 인자로 float4 값 
                (즉, tex2D() 함수로 생성한 노말맵 텍스쳐의 텍셀값) 을 받고,
                결과값을 float3 (즉, 위에서 말한 X, Y, Z) 로 받음.

                이 값을 SurfaceOutputStandard(스탠다드 쉐이더) 구조체의 
                Normal 값에 넣어주면 노말맵이 적용됨!
            */
            fixed3 n = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
            // o.Normal = n;
            o.Normal = float3(n.x * 2, n.y * 2, n.z); // 이런 식으로 float3 n 값을 미리 구해놓은 뒤, n.x, y 에 특정 값을 곱해서 넣어주면 노말맵의 강도를 조절할 수 있음.

            o.Albedo = c.rgb;
            o.Metallic = _Metallic;
            o.Smoothness = _Smoothness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
