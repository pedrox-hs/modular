import 'package:example/app/search/domain/entities/result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class DetailsPage extends StatefulWidget {
  final Result? result;
  const DetailsPage({
    Key? key,
    this.result,
  }) : super(key: key);
  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  @override
  Widget build(BuildContext context) {
    print(Modular.args.queryParams['id']);
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.result != null ? widget.result!.nickname : 'Make a search'),
      ),
      body: widget.result != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Hero(
                    tag: widget.result!.image,
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(widget.result!.image),
                    ),
                  ),
                  Text(widget.result!.nickname),
                ],
              ),
            )
          : Center(
              child: ElevatedButton(
                onPressed: () => Modular.to.pushReplacementNamed('/'),
                child: Text('Make a search'),
              ),
            ),
    );
  }
}
