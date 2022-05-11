Shader "Custom/surface"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Metallic("Metalic", Range(0, 1)) = 0
        _Smoothness ("Smoothness", Range(0, 1)) = 0.5
        _BumpMap ("Normalmap", 2D) = "bump" {} // 유니티는 인터페이스로부터 입력받는 변수명을 '_BumpMap' 이라고 지으면, 텍스쳐 인터페이스는 노말맵을 넣을 것이라고 인지함. 그래서 노말맵 텍스쳐를 입력하지 않을거면 다른 일반 인터페이스를 쓰라고 경고메시지를 띄움.
        _Occlusion ("Occlusion", 2D) = "white" {} // 오클루전 텍스쳐를 받기 위해 추가한 인터페이스
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard

        sampler2D _MainTex;
        sampler2D _BumpMap;
        sampler2D _Occlusion; // 오클루전 텍스쳐가 들어갈 변수
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

            /*
                SurfaceOutputStandard(스탠다드 쉐이더) 구조체의 오클루전 값은 half, 즉
                1개의 float 값만을 받음.

                왜 그러냐?
                오클루전 맵 텍스쳐를 봐도 알겠지만
                흑백으로 되어있잖아!

                흑백으로 되어있으면 당연히 
                float 값 1개만 가지고도 표현이 가능한거지.

                환경광이 닿지 못하는 영역의 
                환경 차폐 그림자값을 표현하려는 거니까.

                그런데 지금 float4 텍셀값을 리턴해주는 tex2D 함수의
                리턴값으로 할당하고 있지?

                이럴 경우, float4 의 첫 번째 값, 즉 r 채널 값만 사용하고,
                나머지 채널의 값들은 그냥 버려짐.

                그래서 o.Occlusion 에는 1개의 값만 들어가게 되는 것!
            */
            o.Occlusion = tex2D(_Occlusion, IN.uv_MainTex); // 참고로 오클루전 맵의 텍셀값을 o.Occlusion 에 할당할 때, 독립된 uv 버텍스 좌표값을 받으면 에러가 나고, 대신 _MainTex 에서 사용하는 것과 동일한 uv 를 사용해야 정상 작동한다고 함!

            o.Albedo = c.rgb;
            o.Metallic = _Metallic;
            o.Smoothness = _Smoothness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}

/*
    Occlusion 에 대한 설명은 p.231 참고.

    오클루전 텍스쳐는 텍셀값의 r값만 사용하기 때문에,
    rgba 값을 모두 갖는 텍스쳐 한장을 가져오는 건 약간 낭비일 수 있음.

    책에서는 _MainTex 의 알파값을 
    오클루전 텍스쳐의 한 자리수 값인 r채널 값으로 넣어서
    텍스쳐를 절약하는 형태로 사용할 수도 있다고 함.
*/